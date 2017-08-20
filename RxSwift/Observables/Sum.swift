//
//  Sum.swift
//  RxSwift
//
//  Created by Shai Mishali on 8/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Emits the sum of all elements emitted from the source Observable using a provided accumulator closure and seed value.

     - parameter seed: Seed value.
     - parameter accumulator: A closure returning the sum of two elements.
     - returns: An observable sequence containing the specified number of elements from the end of the source sequence.
     */
    public func sum(seed: E, _ accumulator: @escaping (E, E) -> E)
        -> Observable<E> {
            return Sum(source: asObservable(), seed: seed, accumulator: accumulator)
    }
}

extension ObservableType where E: Numeric {

    /**
     Emits the sum of all elements emitted from the source Observable.

     - returns: An observable sequence containing the specified number of elements from the end of the source sequence.
     */
    public func sum()
        -> Observable<E> {
            return Sum(source: asObservable(), seed: 0) { $0 + $1 }
    }
}

final fileprivate class SumSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias E = O.E
    typealias Parent = Sum<E>
    typealias Accumulated = E

    private var _parent: Parent
    private var _accumulated: Accumulated

    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        _accumulated = parent._accumulated

        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            _accumulated = _parent._accumulator(_accumulated, value)
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            forwardOn(.next(_accumulated))
            forwardOn(.completed)
            dispose()
        }
    }
}

final fileprivate class Sum<Element>: Producer<Element> {
    typealias Accumulator = (E, E) -> E
    typealias Accumulated = E

    private let _source: Observable<Element>
    fileprivate let _accumulator: Accumulator
    fileprivate let _accumulated: Accumulated

    init(source: Observable<Element>, seed: Element, accumulator: @escaping Accumulator) {
        _source = source
        _accumulator = accumulator
        _accumulated = seed
    }

    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        let sink = SumSink(parent: self, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
