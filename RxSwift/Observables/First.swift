//
//  First.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/31/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

private final class FirstSink<Element, Observer: ObserverType>: Sink<Observer>, ObserverType where Observer.Element == Element? {
    typealias Parent = First<Element>

    func on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            forwardOn(.next(value))
            forwardOn(.completed)
            dispose()
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.next(nil))
            forwardOn(.completed)
            dispose()
        }
    }
}

final class First<Element>: Producer<Element?> {
    private let source: Observable<Element>

    init(source: Observable<Element>) {
        self.source = source
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element? {
        let sink = FirstSink(observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
