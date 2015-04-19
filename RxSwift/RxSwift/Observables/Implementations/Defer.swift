//
//  Defer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Defer_<ElementType> : Sink<ElementType>, ObserverClassType {
    typealias Parent = Defer<Element>
    typealias Element = ElementType
    
    let parent: Parent
    
    init(parent: Parent, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        return parent.eval() >== { result in
            return result.subscribeSafe(ObserverOf(self))
        } >>! { e in
            _ = self.observer.on(.Error(e))
            self.dispose()
            return success(DefaultDisposable())
        }
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            return observer.on(event)
        case .Error:
            let result = observer.on(event)
            dispose()
            return result
        case .Completed:
            let result = observer.on(event)
            dispose()
            return result
        }
    }
}

class Defer<Element> : Producer<Element> {
    typealias Factory = () -> Result<Observable<Element>>
    
    let observableFactory : Factory
    
    init(observableFactory: Factory) {
        self.observableFactory = observableFactory
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = Defer_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
    func eval() -> Result<Observable<Element>> {
        return observableFactory()
    }
}