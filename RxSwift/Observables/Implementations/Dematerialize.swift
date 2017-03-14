//
//  Dematerialize.swift
//  Rx
//
//  Created by Jamie Pinkham on 3/13/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

fileprivate final class DematerializeSink<E: EventType, O: ObserverType>: Sink<O>, ObserverType where O.E == E.E {
    fileprivate func on(_ event: Event<E>) {
        switch event {
        case .next(let element):
            forwardOn(element.event)
            if element.event.isStopEvent {
                dispose()
            }
        case .completed:
            forwardOn(.completed)
            dispose()
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        }
    }
}

final class Dematerialize<Element: EventType>: Producer<Element.E>  {
    private let _source: Observable<Element>
    
    init(source: Observable<Element>) {
        _source = source
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element.E {
        let sink = DematerializeSink<Element, O>(observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
