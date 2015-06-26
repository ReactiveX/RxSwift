//
//  Zip.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol ZipSinkProtocol : class
{
    func next(index: Int)
    func fail(error: ErrorType)
    func done(index: Int)
}

class ZipSink<O: ObserverType> : Sink<O>, ZipSinkProtocol {
    typealias Element = O.Element
    
    let arity: Int
    
    let lock = NSRecursiveLock()
    
    // state
    var isDone: [Bool]
    
    init(arity: Int, observer: O, cancel: Disposable) {
        self.isDone = [Bool](count: arity, repeatedValue: false)
        self.arity = arity
        
        super.init(observer: observer, cancel: cancel)
    }

    func getResult() -> RxResult<Element> {
        return abstractMethod()
    }
    
    func hasElements(index: Int) -> Bool {
        return abstractMethod()
    }
    
    func next(index: Int) {
        var hasValueAll = true
        
        for i in 0 ..< arity {
            if !hasElements(i) {
                hasValueAll = false;
                break;
            }
        }
        
        if hasValueAll {
            _ = getResult().flatMap { result in
                trySendNext(self.observer, result)
                return SuccessResult
            }.recoverWith { e -> RxResult<Void> in
                trySendError(self.observer, e)
                dispose()
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
}

class ZipObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    typealias ValueSetter = (ElementType) -> ()

    var parent: ZipSinkProtocol?
    
    let lock: NSRecursiveLock
    let index: Int
    let this: Disposable
    let setNextValue: ValueSetter
    
    init(lock: NSRecursiveLock, parent: ZipSinkProtocol, index: Int, setNextValue: ValueSetter, this: Disposable) {
        self.lock = lock
        self.parent = parent
        self.index = index
        self.this = this
        self.setNextValue = setNextValue
    }
    
    func on(event: Event<Element>) {
       
        if let parent = parent {
            switch event {
            case .Next(let boxedValue):
                break
            case .Error(let error):
                this.dispose()
            case .Completed:
                this.dispose()
            }
        }
        
        lock.performLocked {
            if let parent = parent {
                switch event {
                case .Next(let boxedValue):
                    setNextValue(boxedValue.value)
                    parent.next(index)
                case .Error(let error):
                    parent.fail(error)
                case .Completed:
                    parent.done(index)
                }
            }
        }
    }
}
