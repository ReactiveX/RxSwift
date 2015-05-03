//
//  CombineLatest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol CombineLatestProtocol : class {
    func performLocked(@noescape action: () -> Void)
    
    func next(index: Int)
    func fail(error: ErrorType)
    func done(index: Int)
}

class CombineLatestSink<Element> : Sink<Element>, CombineLatestProtocol {
    var lock = NSRecursiveLock()
    
    var hasValueAll: Bool
    var hasValue: [Bool]
    var isDone: [Bool]
    
    init(arity: Int, observer: ObserverOf<Element>, cancel: Disposable) {
        self.hasValueAll = false
        self.hasValue = [Bool](count: arity, repeatedValue: false)
        self.isDone = [Bool](count: arity, repeatedValue: false)
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func getResult() -> Result<Element> {
        return abstractMethod()
    }
   
    func performLocked(@noescape action: () -> Void) {
        return lock.calculateLocked(action)
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
            let maybeRes = getResult()
            
            _ = maybeRes >== { res in
                self.observer.on(.Next(Box(res)))
                return SuccessResult
            } >>! { e -> Result<Void> in
                self.observer.on(.Error(e))
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
                self.observer.on(.Completed)
                self.dispose()
            }
        }
    }
    
    func fail(error: ErrorType) {
        self.observer.on(.Error(error))
        self.dispose()
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
            observer.on(.Completed)
            self.dispose()
        }
    }
}

class CombineLatestObserver<Element> : ObserverType {
    unowned let _parent: CombineLatestProtocol
    let _index: Int
    let _this: Disposable
    var _value: Element!
    
    init(parent: CombineLatestProtocol, index: Int, this: Disposable) {
        _parent = parent
        _index = index
        _this = this
        _value = nil
    }
    
    var value: Element {
        get {
            return _value!
        }
    }
    
    func on(event: Event<Element>) {
        _parent.performLocked {
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self._value = value
                self._parent.next(_index)
            case .Error(let error):
                self._this.dispose()
                self._parent.fail(error)
            case .Completed:
                self._this.dispose()
                self._parent.done(_index)
            }
        }
    }
}