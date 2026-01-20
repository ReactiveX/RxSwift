//
//  Scan.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.

     For aggregation behavior with no intermediate results, see `reduce`.

     - seealso: [scan operator on reactivex.io](http://reactivex.io/documentation/operators/scan.html)

     - parameter seed: The initial accumulator value.
     - parameter accumulator: An accumulator function to be invoked on each element.
     - returns: An observable sequence containing the accumulated values.
     */
    func scan<A>(into seed: A, accumulator: @escaping (inout A, Element) throws -> Void)
        -> Observable<A>
    {
        Scan(source: asObservable(), seed: seed, accumulator: accumulator)
    }

    /**
     Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.

     For aggregation behavior with no intermediate results, see `reduce`.

     - seealso: [scan operator on reactivex.io](http://reactivex.io/documentation/operators/scan.html)

     - parameter seed: The initial accumulator value.
     - parameter accumulator: An accumulator function to be invoked on each element.
     - returns: An observable sequence containing the accumulated values.
     */
    func scan<A>(_ seed: A, accumulator: @escaping (A, Element) throws -> A)
        -> Observable<A>
    {
        Scan(source: asObservable(), seed: seed) { acc, element in
            let currentAcc = acc
            acc = try accumulator(currentAcc, element)
        }
    }
}

private final class ScanSink<Element, Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Accumulate = Observer.Element
    typealias Parent = Scan<Element, Accumulate>

    private let parent: Parent
    private var accumulate: Accumulate

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        accumulate = parent.seed
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        switch event {
        case let .next(element):
            do {
                try parent.accumulator(&accumulate, element)
                forwardOn(.next(accumulate))
            } catch {
                forwardOn(.error(error))
                dispose()
            }
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

private final class Scan<Element, Accumulate>: Producer<Accumulate> {
    typealias Accumulator = (inout Accumulate, Element) throws -> Void

    private let source: Observable<Element>
    fileprivate let seed: Accumulate
    fileprivate let accumulator: Accumulator

    init(source: Observable<Element>, seed: Accumulate, accumulator: @escaping Accumulator) {
        self.source = source
        self.seed = seed
        self.accumulator = accumulator
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Accumulate {
        let sink = ScanSink(parent: self, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
