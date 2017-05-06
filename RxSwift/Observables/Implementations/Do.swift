//
//  Do.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

final class DoSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias EventHandler = (Event<Element>) throws -> Void
    
    private let _eventHandler: EventHandler
    
    init(eventHandler: @escaping EventHandler, observer: O, cancel: Cancelable) {
        _eventHandler = eventHandler
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        do {
            try _eventHandler(event)
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

final class Do<Element> : Producer<Element> {
    typealias EventHandler = (Event<Element>) throws -> Void
    
    fileprivate let _source: Observable<Element>
    fileprivate let _eventHandler: EventHandler
    fileprivate let _onSubscribe: (() -> ())?
    fileprivate let _onSubscribed: (() -> ())?
    fileprivate let _onDispose: (() -> ())?
    
    init(source: Observable<Element>, eventHandler: @escaping EventHandler, onSubscribe: (() -> ())?, onSubscribed: (() -> ())?, onDispose: (() -> ())?) {
        _source = source
        _eventHandler = eventHandler
        _onSubscribe = onSubscribe
        _onSubscribed = onSubscribed
        _onDispose = onDispose
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        _onSubscribe?()
        let sink = DoSink(eventHandler: _eventHandler, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        _onSubscribed?()
        let onDispose = _onDispose
        let allSubscriptions = Disposables.create {
            subscription.dispose()
            onDispose?()
        }
        return (sink: sink, subscription: allSubscriptions)
    }
}
