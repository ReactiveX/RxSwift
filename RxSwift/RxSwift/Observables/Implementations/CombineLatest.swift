//
//  CombineLatest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol CombineLatestProtocol : class {
    func next(index: Int)
    func fail(error: ErrorType)
    func done(index: Int)
}

class CombineLatestSink<O: ObserverType> : Sink<O>, CombineLatestProtocol {
    typealias Element = O.Element
   
    var lock = NSRecursiveLock()
    
    var hasValueAll: Bool
    var hasValue: [Bool]
    var isDone: [Bool]
   
    init(arity: Int, observer: O, cancel: Disposable) {
        self.hasValueAll = false
        self.hasValue = [Bool](count: arity, repeatedValue: false)
        self.isDone = [Bool](count: arity, repeatedValue: false)
        
        super.init(observer: observer, cancel: cancel)
    }
    
    /* abstract */ func getResult() -> RxResult<Element> {
        return abstractMethod()
    }
    
    func next(index: Int) {
        if !hasValueAll {
            hasValue[index] = true
            
            var hasValueAll = true
            for hasValue in self.hasValue {
                if !hasValue {
                    hasValueAll = false;
                    break;
                }
            }
            
            self.hasValueAll = hasValueAll;
        }
        
        if hasValueAll {
            _ = getResult().flatMap { res in
                trySendNext(observer, res)
                return SuccessResult
            }.recoverWith { e -> RxResult<Void> in
                trySendError(observer, e)
                self.dispose()
                return SuccessResult
            }
        }
        else {
            var allOthersDone = true
            
            var arity = self.isDone.count
            for var i = 0; i < arity; ++i {
                if i != index && !isDone[i] {
                    allOthersDone = false
                    break
                }
            }
            
            if allOthersDone {
                trySendCompleted(observer)
                self.dispose()
            }
        }
    }
    
    func fail(error: ErrorType) {
        trySendError(observer, error)
        dispose()
    }
    
    func done(index: Int) {
        isDone[index] = true
        
        var allDone = true
        
        for done in self.isDone {
            if !done {
                allDone = false
                break
            }
        }
        
        if allDone {
            trySendCompleted(observer)
            dispose()
        }
    }
    
    deinit {
        
    }
}

class CombineLatestObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    typealias ValueSetter = (Element) -> Void
    
    let parent: CombineLatestProtocol
    
    let lock: NSRecursiveLock
    let index: Int
    let this: Disposable
    let setLatestValue: ValueSetter
    
    init(lock: NSRecursiveLock, parent: CombineLatestProtocol, index: Int, setLatestValue: ValueSetter, this: Disposable) {
        self.lock = lock
        self.parent = parent
        self.index = index
        self.this = this
        self.setLatestValue = setLatestValue
    }
    
    func on(event: Event<Element>) {
        lock.performLocked {
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                setLatestValue(value)
                parent.next(index)
            case .Error(let error):
                this.dispose()
                parent.fail(error)
            case .Completed:
                this.dispose()
                parent.done(index)
            }
        }
    }
}