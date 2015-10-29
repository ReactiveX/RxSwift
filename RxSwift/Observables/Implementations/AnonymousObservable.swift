//
//  AnonymousObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Darwin

class AnonymousObservableSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias E = O.E
    typealias Parent = AnonymousObservable<E>
    
    // state
    private var _isStopped: Int32 = 0

    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next:
            if _isStopped == 1 {
                return
            }
            observer?.on(event)
        case .Error, .Completed:
            if OSAtomicCompareAndSwap32(0, 1, &_isStopped) {
                self.observer?.on(event)
                self.dispose()
            }
        }
    }
    
    func run(parent: Parent) -> Disposable {
        return parent._subscribeHandler(AnyObserver(self))
    }
}

public class AnonymousObservable<Element> : Producer<Element> {
    public typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable

    public let _subscribeHandler: SubscribeHandler
    
    public init(_ subscribeHandler: SubscribeHandler) {
        _subscribeHandler = subscribeHandler
    }
    
    public override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run(self)
    }
}
