//
//  AsSingle.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

private final class AsSingleSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element

    private var element: Event<Element>?

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            if element != nil {
                forwardOn(.error(RxError.moreThanOneElement))
                dispose()
            }

            element = event
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            if let element {
                forwardOn(element)
                forwardOn(.completed)
            } else {
                forwardOn(.error(RxError.noElements))
            }
            dispose()
        }
    }
}

final class AsSingle<Element>: Producer<Element> {
    private let source: Observable<Element>

    init(source: Observable<Element>) {
        self.source = source
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = AsSingleSink(observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
