//
//  Min.swift
//  RxSwift
//
//  Created by Shai Mishali on 8/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Emits the item from the source Observable that had the minimum value using a provided comparator closure.

     - parameter comparator: A comparator method expected to return true if the first element has a lower value then the second element.
     - returns: An observable sequence containing the specified number of elements from the end of the source sequence.
    */
    public func min(_ comparator: @escaping (E, E) -> Bool)
        -> Observable<E> {
            return Min(source: asObservable(), comparator: comparator)
    }
}

extension ObservableType where E: Comparable {
    /**
     Emits the item from the source Observable that had the minimum value.

     - returns: An observable sequence containing the specified number of elements from the end of the source sequence.
     */
    public func min()
        -> Observable<E> {
            return Min(source: asObservable()) { $0 < $1 }
    }
}

final fileprivate class MinSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias E = O.E
    typealias Comparator = (E, E) -> Bool

    private let _comparator: Comparator
    private var _min: E?

    init(comparator: @escaping Comparator, observer: O, cancel: Cancelable) {
        _comparator = comparator
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            guard let min = _min else {
                _min = value
                return
            }

            _min = _comparator(min, value) ? _min : value
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            if let min = _min {
                forwardOn(.next(min))
            }

            forwardOn(.completed)
            dispose()
        }
    }
}

final fileprivate class Min<Element>: Producer<Element> {
    typealias Comparator = (E, E) -> Bool

    private let _source: Observable<Element>
    private let _comparator: Comparator

    init(source: Observable<Element>, comparator: @escaping Comparator) {
        _source = source
        _comparator = comparator
    }

    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        let sink = MinSink(comparator: _comparator, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
