//
//  CombineLatest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol CombineLatestProtocol : class {
    func performLocked(@noescape action: () -> Result<Void>) -> Result<Void>
    
    func next(index: Int) -> Result<Void>
    func fail(error: ErrorType) -> Result<Void>
    func done(index: Int) -> Result<Void>
}

class CombineLatestSink<Element> : Sink<Element>, CombineLatestProtocol {
    var lock: Lock = Lock()
    
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
   
    func performLocked(@noescape action: () -> Result<Void>) -> Result<Void> {
        return lock.calculateLocked(action)
    }
    
    func next(index: Int) -> Result<Void> {
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
            
            return maybeRes >== { res in
                return self.observer.on(.Next(Box(res)))
            } >>! { e in
                let result = self.observer.on(.Error(e))
                self.dispose()
                return result
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
                let result = self.observer.on(.Completed)
                self.dispose()
                return result
            }
        }
        
        return SuccessResult
    }
    
    func fail(error: ErrorType) -> Result<Void> {
        let result = self.observer.on(.Error(error))
        self.dispose()
        return result
    }
    
    func done(index: Int) -> Result<Void> {
        isDone[index] = true
        
        var allDone = true
        
        for done in self.isDone {
            if !done {
                allDone = false
                break
            }
        }
        
        if allDone {
            let result = observer.on(.Completed)
            self.dispose()
            return result
        }
        else {
            return SuccessResult
        }
    }
}

class CombineLatestObserver<Element> : ObserverClassType {
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
    
    func on(event: Event<Element>) -> Result<Void> {
        return _parent.performLocked {
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self._value = value
                return self._parent.next(_index)
            case .Error(let error):
                self._this.dispose()
                return self._parent.fail(error)
            case .Completed:
                self._this.dispose()
                return self._parent.done(_index)
            }
        }
    }
}