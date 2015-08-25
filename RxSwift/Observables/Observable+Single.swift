//
//  Observable+Single.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// as observable

/* part of interface now
extension ObservableType {
    public func asObservable() -> Observable<E> {
        if let asObservable = self as? AsObservable<E> {
            return asObservable.omega()
        }
        else {
            return AsObservable(source: self.asObservable())
        }
    }
}
*/

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
        return DistinctUntilChanged(source: self.asObservable(), selector: keySelector, comparer: comparer)
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
        return DistinctUntilChanged(source: self.asObservable(), selector: keySelector, comparer: comparer)
    }
}

// do

extension ObservableType {
    public func doOn(eventHandler: (Event<E>) throws -> Void)
        -> Observable<E> {
        return Do(source: self.asObservable(), eventHandler: eventHandler)
    }

    public func doOn(next next: (E throws -> Void)? = nil, error: (ErrorType throws -> Void)? = nil, completed: (() throws -> Void)? = nil, disposed: (() throws -> Void)? = nil)
        -> Observable<E> {
        return Do(source: self.asObservable()) { e in
            switch e {
            case .Next(let element):
                try next?(element)
            case .Error(let e):
                try error?(e)
                try disposed?()
            case .Completed:
                try completed?()
                try disposed?()
            }
        }
    }
}

// startWith

extension ObservableType {
    // Prefixes observable sequence with `firstElement` element.
    // The same functionality could be achieved using `concat([just(prefix), source])`,
    // but this is significantly more efficient implementation.
    public func startWith(elements: E ...)
        -> Observable<E> {
        return StartWith(source: self.asObservable(), elements: elements)
    }
}

// retry

extension ObservableType {
    public var retry: Observable<E> {
        return CatchSequence(sources: AnySequence(InifiniteSequence(repeatedValue: self.asObservable())))
    }

    public func retry(retryCount: Int)
        -> Observable<E> {
        return CatchSequence(sources: AnySequence(Repeat(count: retryCount, repeatedValue: self.asObservable())))
    }
}

// scan

extension ObservableType {
    
    public func scan<A>(seed: A, accumulator: (A, E) throws -> A)
        -> Observable<A> {
        return Scan(source: self.asObservable(), seed: seed, accumulator: accumulator)
    }
    
}