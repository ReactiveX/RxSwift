//
//  Catch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Catch_Impl<ElementType> : ObserverClassType {
    typealias Element = ElementType
    typealias Parent = Catch_<Element>
    
    let parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    func on(event: Event<ElementType>) -> Result<Void> {
        let result = parent.observer.on(event)
        
        switch event {
        case .Next:
            break
        case .Error:
            parent.dispose()
        case .Completed:
            parent.dispose()
        }
        
        return result
    }
}

class Catch_<ElementType> : Sink<ElementType>, ObserverClassType {
    typealias Element = ElementType
    typealias Parent = Catch<Element>
    
    let parent: Parent
    let subscription = SerialDisposable()
    
    init(parent: Parent, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        let d1 = SingleAssignmentDisposable()
        subscription.setDisposable(d1)
        return parent.source.subscribeSafe(ObserverOf(self)) >== { disposableSubscription in
            d1.setDisposable(disposableSubscription)
        } >>> {
            success(subscription)
        }
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            return self.observer.on(event)
        case .Completed:
            let result = self.observer.on(event)
            self.dispose()
            return result
        case .Error(let error):
            return parent.handler(error) >>! { error2 in
                let result = self.observer.on(.Error(error2))
                self.dispose()
                return result >>> {
                    return .Error(error2)
                }
            } >== { catchObservable in
                let d = SingleAssignmentDisposable()
                subscription.setDisposable(d)
                
                let observer = ObserverOf(Catch_Impl(parent: self))
                
                return catchObservable.subscribeSafe(observer) >== { subscription2 in
                    d.setDisposable(subscription2)
                    return SuccessResult
                }
            }
        }
    }
}

class Catch<Element> : Producer<Element> {
    typealias Handler = (ErrorType) -> Result<Observable<Element>>
    
    let source: Observable<Element>
    let handler: Handler
    
    init(source: Observable<Element>, handler: Handler) {
        self.source = source
        self.handler = handler
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = Catch_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

class CatchToResult_<ElementType> : Sink<Result<ElementType>>, ObserverClassType {
    typealias Element = ElementType
    typealias Parent = CatchToResult<ElementType>
    
    let parent: Parent
    
    init(parent: Parent, observer: ObserverOf<Result<ElementType>>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        return parent.source.subscribeSafe(ObserverOf(self))
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            return self.observer.on(.Next(Box(success(value))))
        case .Completed:
            let result = self.observer.on(.Completed)
            self.dispose()
            return result
        case .Error(let error):
            let result = self.observer.on(.Next(Box(.Error(error)))) >>> {
                self.observer.on(.Completed)
            }
            self.dispose()
            return result
        }
    }
}

class CatchToResult<Element> : Producer<Result<Element>> {
    let source: Observable<Element>
    
    init(source: Observable<Element>) {
        self.source = source
    }
    
    override func run(observer: ObserverOf<Result<Element>>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = CatchToResult_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}