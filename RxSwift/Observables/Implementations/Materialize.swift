//
//  Materialize.swift
//  RxSwift
//
//  Created by sergdort on 08/03/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol EventType {
    associatedtype E
    
    var event: Event<E> { get }
}

extension Event : EventType {
    public typealias E = Element
    
    public var event: Event<E> {
        return self
    }
}

fileprivate final class MaterializeSink<Element, O: ObserverType>: Sink<O>, ObserverType where O.E == Event<Element> {
    
    func on(_ event: Event<Element>) {
        forwardOn(.next(event))
        if event.isStopEvent {
            forwardOn(.completed)
            dispose()
        }
    }
}

final class Materialize<E>: Producer<Event<E>> {
    private let _source: Observable<E.E>
    
    init(source: Observable<E.E>) {
        _source = source
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == E {
        let sink = MaterializeSink(observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)

        return (sink: sink, subscription: subscription)
    }
}
