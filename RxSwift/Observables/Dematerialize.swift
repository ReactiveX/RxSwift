//
//  Dematerialize.swift
//  RxSwift
//
//  Created by Jamie Pinkham on 3/13/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType where Element: EventConvertible {
    /**
     Convert any previously materialized Observable into it's original form.
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     - returns: The dematerialized observable sequence.
     */
    public func dematerialize() -> Observable<Element.ElementType> {
        return Dematerialize(source: self.asObservable())
    }

}

fileprivate final class DematerializeSink<T: EventConvertible, O: ObserverType>: Sink<O>, ObserverType where O.Element == T.ElementType {
    fileprivate func on(_ event: Event<T>) {
        switch event {
        case .next(let element):
            self.forwardOn(element.event)
            if element.event.isStopEvent {
                self.dispose()
            }
        case .completed:
            self.forwardOn(.completed)
            self.dispose()
        case .error(let error):
            self.forwardOn(.error(error))
            self.dispose()
        }
    }
}

final private class Dematerialize<T: EventConvertible>: Producer<T.ElementType> {
    private let _source: Observable<T>

    init(source: Observable<T>) {
        self._source = source
    }

    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.Element == T.ElementType {
        let sink = DematerializeSink<T, O>(observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
