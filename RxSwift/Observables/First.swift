//
//  First.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/31/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

fileprivate final class FirstSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias ElementType = O.E
    typealias Parent = First<ElementType>
    typealias E = ElementType

    private var _parent: Parent

    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            forwardOn(.next(value))
            forwardOn(.completed)
            dispose()
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            if let defaultElement = _parent._defaultItem {
                forwardOn(.next(defaultElement))
                forwardOn(.completed)
            } else {
                forwardOn(.error(RxError.noElements))
            }
            dispose()
        }
    }
}

final class First<Element>: Producer<Element> {
    fileprivate let _source: Observable<Element>
    fileprivate let _defaultItem: E?

    init(source: Observable<Element>, defaultItem: E? = nil) {
        _source = source
        _defaultItem = defaultItem
    }

    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        let sink = FirstSink(parent: self, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
