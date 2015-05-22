//
//  Defer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Defer_<ElementType> : Sink<ElementType>, ObserverType {
    typealias Parent = Defer<Element>
    typealias Element = ElementType
    
    let parent: Parent
    
    init(parent: Parent, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let disposable = parent.eval().flatMap { result in
            return success(result.subscribe(self))
        }.recoverWith { e in
            sendError(observer, e)
            self.dispose()
            return success(DefaultDisposable())
        }
        
        return disposable.get()
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next:
            observer.on(event)
        case .Error:
            observer.on(event)
            dispose()
        case .Completed:
            observer.on(event)
            dispose()
        }
    }
}

class Defer<Element> : Producer<Element> {
    typealias Factory = () -> RxResult<Observable<Element>>
    
    let observableFactory : Factory
    
    init(observableFactory: Factory) {
        self.observableFactory = observableFactory
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Defer_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
    func eval() -> RxResult<Observable<Element>> {
        return observableFactory()
    }
}