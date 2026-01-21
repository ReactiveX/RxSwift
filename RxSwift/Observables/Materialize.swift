//
//  Materialize.swift
//  RxSwift
//
//  Created by sergdort on 08/03/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Convert any Observable into an Observable of its events.
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     - returns: An observable sequence that wraps events in an Event<E>. The returned Observable never errors, but it does complete after observing all of the events of the underlying Observable.
     */
    func materialize() -> Observable<Event<Element>> {
        Materialize(source: asObservable())
    }
}

private final class MaterializeSink<Element, Observer: ObserverType>: Sink<Observer>, ObserverType where Observer.Element == Event<Element> {
    func on(_ event: Event<Element>) {
        forwardOn(.next(event))
        if event.isStopEvent {
            forwardOn(.completed)
            dispose()
        }
    }
}

private final class Materialize<T>: Producer<Event<T>> {
    private let source: Observable<T>

    init(source: Observable<T>) {
        self.source = source
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = MaterializeSink(observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)

        return (sink: sink, subscription: subscription)
    }
}
