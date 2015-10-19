//
//  Deferred.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DeferredSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias E = O.E
    typealias Parent = Deferred<E>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        do {
            let result = try _parent.eval()
            return result.subscribeSafe(self)
        }
        catch let e {
            observer?.on(.Error(e))
            dispose()
            return NopDisposable.instance
        }
    }
    
    func on(event: Event<E>) {
        observer?.on(event)
        
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

class Deferred<Element> : Producer<Element> {
    typealias Factory = () throws -> Observable<Element>
    
    private let _observableFactory : Factory
    
    init(observableFactory: Factory) {
        _observableFactory = observableFactory
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DeferredSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
    
    func eval() throws -> Observable<Element> {
        return try _observableFactory()
    }
}