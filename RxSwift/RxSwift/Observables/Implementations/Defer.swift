//
//  Defer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Defer_<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias Parent = Defer<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let disposable = parent.eval().flatMap { result in
            return success(result.subscribeSafe(self))
        }.recoverWith { e in
            trySendError(observer, e)
            self.dispose()
            return NopDisposableResult
        }
        
        return disposable.get()
    }
    
    func on(event: Event<Element>) {
        trySend(observer, event)
        
        switch event {
        case .Next:
            break
        case .Error:
            dispose()
        case .Completed:
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
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Defer_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
    func eval() -> RxResult<Observable<Element>> {
        return observableFactory()
    }
}