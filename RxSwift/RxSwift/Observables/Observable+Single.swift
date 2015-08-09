//
//  Observable+Single.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// as observable

extension ObservableType {
    public func asObservable() -> Observable<E> {
        if let asObservable = self as? AsObservable<E> {
            return asObservable.omega()
        }
        else {
            return AsObservable(source: self.normalize())
        }
    }
}

// distinct until changed

extension ObservableType where E: Equatable {
    public func distinctUntilChangedOrDie()
        -> Observable<E> {
        return self.distinctUntilChangedOrDie({ success($0) }, { success($0 == $1) })
    }

    public func distinctUntilChanged()
        -> Observable<E> {
        return self.distinctUntilChanged({ $0 }, { ($0 == $1) })
    }
}

extension ObservableType {
    public func distinctUntilChangedOrDie<K: Equatable>(keySelector: (E) -> RxResult<K>)
        -> Observable<E> {
        return self.distinctUntilChangedOrDie(keySelector, { success($0 == $1) })
    }

    public func distinctUntilChangedOrDie(comparer: (lhs: E, rhs: E) -> RxResult<Bool>)
        -> Observable<E> {
        return self.distinctUntilChangedOrDie({ success($0) }, comparer)
    }

    public func distinctUntilChangedOrDie<K>(keySelector: (E) -> RxResult<K>, _ comparer: (lhs: K, rhs: K) -> RxResult<Bool>)
        -> Observable<E> {
        return DistinctUntilChanged(source: self.normalize(), selector: keySelector, comparer: comparer)
    }

    public func distinctUntilChanged<K: Equatable>(keySelector: (E) -> K)
        -> Observable<E> {
        return distinctUntilChanged(keySelector, { ($0 == $1) })
    }

    public func distinctUntilChanged(comparer: (lhs: E, rhs: E) -> Bool)
        -> Observable<E> {
        return distinctUntilChanged({ ($0) }, comparer)
    }

    public func distinctUntilChanged<K>(keySelector: (E) -> K, _ comparer: (lhs: K, rhs: K) -> Bool)
        -> Observable<E> {
        return DistinctUntilChanged(source: self.normalize(), selector: {success(keySelector($0)) }, comparer: { success(comparer(lhs: $0, rhs: $1))})
    }
}

// do

extension ObservableType {
    public func doOrDie(eventHandler: (Event<E>) -> RxResult<Void>)
        -> Observable<E> {
        return Do(source: self.normalize(), eventHandler: eventHandler)
    }

    public func `do`(eventHandler: (Event<E>) -> Void)
        -> Observable<E> {
        return Do(source: self.normalize(), eventHandler: { success(eventHandler($0)) })
    }
}

// doOnNext

extension ObservableType {
    public func doOnNext(actionOnNext: E -> Void)
        -> Observable<E> {
        return self.`do` { event in
            switch event {
            case .Next(let value):
                actionOnNext(value)
            default:
                break
            }
        }
    }
}

// startWith

extension ObservableType {
    // Prefixes observable sequence with `firstElement` element.
    // The same functionality could be achieved using `concat([just(prefix), source])`,
    // but this is significantly more efficient implementation.
    public func startWith(firstElement: E)
        -> Observable<E> {
        return StartWith(source: self.normalize(), element: firstElement)
    }
}

// retry

extension ObservableType {
    public var retry: Observable<E> {
        return CatchSequence(sources: AnySequence(InifiniteSequence(repeatedValue: self.normalize())))
    }

    public func retry(retryCount: Int)
        -> Observable<E> {
        return CatchSequence(sources: AnySequence(Repeat(count: retryCount, repeatedValue: self.normalize())))
    }
}

// scan

extension ObservableType {
    public func scan<A>(seed: A, accumulator: (A, E) -> A)
        -> Observable<A> {
        return Scan(source: self.normalize(), seed: seed, accumulator: { success(accumulator($0, $1)) })
    }

    public func scanOrDie<A>(seed: A, accumulator: (A, E) -> RxResult<A>)
        -> Observable<A> {
        return Scan(source: self.normalize(), seed: seed, accumulator: accumulator)
    }
}