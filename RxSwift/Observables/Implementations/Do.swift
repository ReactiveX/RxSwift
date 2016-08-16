//
//  Do.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DoSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = Do<Element>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func on(_ event: Event<Element>) {
        do {
            try _parent._eventHandler(event)
            forwardOn(event)
            if event.isStopEvent {
                dispose()
            }
        }
        catch let error {
            forwardOn(.error(error))
            dispose()
        }
    }
}

class Do<Element> : Producer<Element> {
    typealias EventHandler = (Event<Element>) throws -> Void
    
    private let _source: Observable<Element>
    private let _eventHandler: EventHandler
    private let _onSubscribe: (() -> ())?
    private let _onDispose: (() -> ())?
    
    init(source: Observable<Element>, eventHandler: EventHandler, onSubscribe: (() -> ())?, onDispose: (() -> ())?) {
        _source = source
        _eventHandler = eventHandler
        _onSubscribe = onSubscribe
        _onDispose = onDispose
    }
    
    override func run<O: ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        _onSubscribe?()
        let sink = DoSink(parent: self, observer: observer)
        let subscription = _source.subscribe(sink)
        let onDispose = _onDispose
        sink.disposable = Disposables.create {
            subscription.dispose()
            onDispose?()
        }
        return sink
    }
}
