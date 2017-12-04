//
//  Enumerated.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/6/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Enumerates the elements of an observable sequence.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - returns: An observable sequence that contains tuples of source sequence elements and their indexes.
     */
    public func enumerated()
        -> Observable<(index: Int, element: E)> {
        return Enumerated(source: self.asObservable())
    }
}

final fileprivate class EnumeratedSink<Element, O : ObserverType>: Sink<O>, ObserverType where O.E == (index: Int, element: Element) {
    typealias E = Element
    var index = 0
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            do {
                let nextIndex = try incrementChecked(&index)
                let next = (index: nextIndex, element: value)
                forwardOn(.next(next))
            }
            catch let e {
                forwardOn(.error(e))
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

final fileprivate class Enumerated<Element> : Producer<(index: Int, element: Element)> {
    private let _source: Observable<Element>

    init(source: Observable<Element>) {
        _source = source
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == (index: Int, element: Element) {
        let sink = EnumeratedSink<Element, O>(observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
