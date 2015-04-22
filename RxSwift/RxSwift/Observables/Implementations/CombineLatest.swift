//
//  CombineLatest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class First<Element1, Element2, ResultType>: ObserverClassType {
    typealias Parent = CombineLatest_<Element1, Element2, ResultType>
    typealias Element = Element1
    
    let parent: Parent
    let disposeSelf: Disposable
    
    var other: Second<Element1, Element2, ResultType>? = nil
   
    // under parent lock
    var value: Element1? = nil
    var done: Bool = false
    
    init(parent: Parent, disposeSelf: Disposable) {
        self.parent = parent
        self.disposeSelf = disposeSelf
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        return parent.lock.calculateLocked { _ in
            let (observer, disposable, disposed) = self.parent.state
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self.value = value
                
                if let otherValue = self.other?.value {
                    let result: Result<ResultType> = self.parent.parent.selector(value, otherValue)
                    
                    return (result >== { res in
                        return observer.on(.Next(Box(res)))
                    }) >>! { e -> Result<Void> in
                        let resul = observer.on(.Error(e))
                        self.parent.dispose()
                        return result >>> { .Error(e) }
                    }
                }
                else if self.other?.done ?? false {
                    let result = observer.on(.Completed)
                    self.parent.dispose()
                    return result
                }
                else {
                   return SuccessResult
                }
            case .Error(let error):
                let result = observer.on(.Error(error))
                self.parent.dispose()
                return result
            case .Completed:
                self.done = true
                if self.other?.done ?? false {
                    let result = observer.on(.Completed)
                    self.parent.dispose()
                    return result
                }
                else {
                    self.disposeSelf.dispose()
                    return SuccessResult
                }
            }
        }
    }
}

class Second<Element1, Element2, ResultType>: ObserverClassType {
    typealias Parent = CombineLatest_<Element1, Element2, ResultType>
    typealias Element = Element2
    
    let parent: Parent
    let disposeSelf: Disposable
    
    var other: First<Element1, Element2, ResultType>? = nil
    
    var value: Element2? = nil
    var done: Bool = false
    
    init(parent: Parent, disposeSelf: Disposable) {
        self.parent = parent
        self.disposeSelf = disposeSelf
        self.other = nil
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        return parent.lock.calculateLocked { _ in
            let (observer, disposable, disposed) = self.parent.state
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self.value = value
                
                if let otherValue = self.other?.value {
                    let result: Result<ResultType> = self.parent.parent.selector(otherValue, value)
                    return (result >== { res in
                        return observer.on(.Next(Box(res)))
                    }) >>! { e -> Result<Void> in
                        let result = observer.on(.Error(e))
                        self.parent.dispose()
                        return result >>> { .Error(e) }
                    }
                }
                else if self.other?.done ?? false {
                    let result = observer.on(.Completed)
                    self.parent.dispose()
                    return result
                }
                else {
                    return SuccessResult
                }
            case .Error(let error):
                let result = observer.on(.Error(error))
                self.parent.dispose()
                return result
            case .Completed:
                self.done = true
                if self.other?.done ?? false {
                    let result = observer.on(.Completed)
                    self.parent.dispose()
                    return result
                }
                else {
                    self.disposeSelf.dispose()
                    return SuccessResult
                }
            }
        }
    }
}


class CombineLatest_<Element1, Element2, ResultType> : Sink<ResultType> {
    typealias Parent = CombineLatest<Element1, Element2, ResultType>
    
    let parent: Parent
    
    var lock = Lock()
    
    init(parent: Parent, observer: ObserverOf<ResultType>, cancel: Disposable) {
        self.parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        let snapshot = self.state
        
        let subscription1 = SingleAssignmentDisposable()
        let subscription2 = SingleAssignmentDisposable()
       
        let sink1 = First(parent: self, disposeSelf: subscription1)
        let sink2 = Second(parent: self, disposeSelf: subscription2)
        
        sink1.other = sink2
        sink2.other = sink1
        
        let removeBond = AnonymousDisposable {
            sink1.other = nil
            sink2.other = nil
        }
        
        return doAll([
            parent.observable1.subscribeSafe(ObserverOf(sink1)) >== { disposable in
                subscription1.setDisposable(disposable)
            },
            parent.observable2.subscribeSafe(ObserverOf(sink2)) >== { disposable in
                subscription2.setDisposable(disposable)
            }
        ]) >>> {
            return success(CompositeDisposable(subscription1, subscription2, removeBond))
        } >>! { e in
            subscription1.dispose()
            subscription2.dispose()
            removeBond.dispose()
            return .Error(e)
        }
    }
}

class CombineLatest<Element1, Element2, ResultType> : Producer<ResultType> {
    typealias SelectorType = (Element1, Element2) -> Result<ResultType>
    
    let observable1: Observable<Element1>
    let observable2: Observable<Element2>
    let selector: SelectorType
    
    init(observable1: Observable<Element1>, observable2: Observable<Element2>, selector: SelectorType) {
        self.observable1 = observable1
        self.observable2 = observable2
        
        self.selector = selector
    }
    
    override func run(observer: ObserverOf<ResultType>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = CombineLatest_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}


protocol CombineLatestProtocol {
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
    let _parent: CombineLatestProtocol
    let _index: Int
    let _this: Disposable
    let _value: Element!
    
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