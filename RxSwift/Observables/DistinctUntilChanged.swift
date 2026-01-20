//
//  DistinctUntilChanged.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType where Element: Equatable {
    /**
     Returns an observable sequence that contains only distinct contiguous elements according to equality operator.

     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

     - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
     */
    func distinctUntilChanged()
        -> Observable<Element>
    {
        distinctUntilChanged {
            $0
        } comparer: {
            $0 == $1
        }
    }
}

public extension ObservableType {
    /**
     Returns an observable sequence that contains only distinct contiguous elements according to the `keySelector`.

     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

     - parameter keySelector: A function to compute the comparison key for each element.
     - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value, from the source sequence.
     */
    func distinctUntilChanged(_ keySelector: @escaping (Element) throws -> some Equatable)
        -> Observable<Element>
    {
        distinctUntilChanged(keySelector, comparer: { $0 == $1 })
    }

    /**
     Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.

     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

     - parameter comparer: Equality comparer for computed key values.
     - returns: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
     */
    func distinctUntilChanged(_ comparer: @escaping (Element, Element) throws -> Bool)
        -> Observable<Element>
    {
        distinctUntilChanged({ $0 }, comparer: comparer)
    }

    /**
     Returns an observable sequence that contains only distinct contiguous elements according to the keySelector and the comparer.

     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

     - parameter keySelector: A function to compute the comparison key for each element.
     - parameter comparer: Equality comparer for computed key values.
     - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value and the comparer, from the source sequence.
     */
    func distinctUntilChanged<K>(_ keySelector: @escaping (Element) throws -> K, comparer: @escaping (K, K) throws -> Bool)
        -> Observable<Element>
    {
        DistinctUntilChanged(source: asObservable(), selector: keySelector, comparer: comparer)
    }

    /**
     Returns an observable sequence that contains only contiguous elements with distinct values in the provided key path on each object.

     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

     - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator on the provided key path
     */
    func distinctUntilChanged(at keyPath: KeyPath<Element, some Equatable>) ->
        Observable<Element>
    {
        distinctUntilChanged { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
    }
}

private final class DistinctUntilChangedSink<Observer: ObserverType, Key>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element

    private let parent: DistinctUntilChanged<Element, Key>
    private var currentKey: Key?

    init(parent: DistinctUntilChanged<Element, Key>, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            do {
                let key = try parent.selector(value)
                var areEqual = false
                if let currentKey {
                    areEqual = try parent.comparer(currentKey, key)
                }

                if areEqual {
                    return
                }

                currentKey = key

                forwardOn(event)
            } catch {
                forwardOn(.error(error))
                dispose()
            }
        case .error, .completed:
            forwardOn(event)
            dispose()
        }
    }
}

private final class DistinctUntilChanged<Element, Key>: Producer<Element> {
    typealias KeySelector = (Element) throws -> Key
    typealias EqualityComparer = (Key, Key) throws -> Bool

    private let source: Observable<Element>
    fileprivate let selector: KeySelector
    fileprivate let comparer: EqualityComparer

    init(source: Observable<Element>, selector: @escaping KeySelector, comparer: @escaping EqualityComparer) {
        self.source = source
        self.selector = selector
        self.comparer = comparer
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = DistinctUntilChangedSink(parent: self, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
