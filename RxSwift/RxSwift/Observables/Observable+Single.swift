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
    public func distinctUntilChanged()
        -> Observable<E> {
        return self.distinctUntilChanged({ $0 }, comparer: { ($0 == $1) })
    }
}

extension ObservableType {
    public func distinctUntilChanged<K: Equatable>(keySelector: (E) throws -> K)
        -> Observable<E> {
        return self.distinctUntilChanged(keySelector, comparer: { $0 == $1 })
    }

    public func distinctUntilChanged(comparer: (lhs: E, rhs: E) throws -> Bool)
        -> Observable<E> {
        return self.distinctUntilChanged({ $0 }, comparer: comparer)
    }

    public func distinctUntilChanged<K>(keySelector: (E) throws -> K, comparer: (lhs: K, rhs: K) throws -> Bool)
        -> Observable<E> {
        return DistinctUntilChanged(source: self.normalize(), selector: keySelector, comparer: comparer)
    }

    public func distinctUntilChanged<K: Equatable>(keySelector: (E) -> K)
        -> Observable<E> {
        return distinctUntilChanged(keySelector, comparer: { ($0 == $1) })
    }

    public func distinctUntilChanged(comparer: (lhs: E, rhs: E) -> Bool)
        -> Observable<E> {
        return distinctUntilChanged({ ($0) }, comparer: comparer)
    }

    public func distinctUntilChanged<K>(keySelector: (E) -> K, comparer: (lhs: K, rhs: K) -> Bool)
        -> Observable<E> {
        return DistinctUntilChanged(source: self.normalize(), selector: keySelector, comparer: comparer)
    }
}

// do

extension ObservableType {
    public func tap(eventHandler: (Event<E>) throws -> Void)
        -> Observable<E> {
        return Tap(source: self.normalize(), eventHandler: eventHandler)
    }
}

// doOnNext

extension ObservableType {
    public func tapOnNext(actionOnNext: E -> Void)
        -> Observable<E> {
        return self.tap { event in
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