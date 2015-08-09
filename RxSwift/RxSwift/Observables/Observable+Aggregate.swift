//
//  Observable+Aggregate.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// aggregate

extension ObservableType {
    public func aggregateOrDie<A, R>
        (seed: A, _ accumulator: (A, E) -> RxResult<A>, _ resultSelector: (A) -> RxResult<R>)
        -> Observable<R> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: accumulator, resultSelector: resultSelector)
    }

    public func aggregateOrDie<A>
        (seed: A, _ accumulator: (A, E) -> RxResult<A>)
        -> Observable<A> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: accumulator, resultSelector: { success($0) })
    }

    public func aggregate<A, R>
        (seed: A, _ accumulator: (A, E) -> A, _ resultSelector: (A) -> R)
        -> Observable<R> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success(resultSelector($0)) })
    }

    public func aggregate<A>
        (seed: A, _ accumulator: (A, E) -> A)
        -> Observable<A> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success($0) })
    }
}

// reduce

extension ObservableType {
    public func reduceOrDie<A, R>
        (seed: A, _ accumulator: (A, E) -> RxResult<A>, _ resultSelector: (A) -> RxResult<R>)
        -> Observable<R> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: accumulator, resultSelector: resultSelector)
    }

    public func reduceOrDie<A>
        (seed: A, _ accumulator: (A, E) -> RxResult<A>)
        -> Observable<A> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: accumulator, resultSelector: { success($0) })
    }

    public func reduce<A, R>
        (seed: A, _ accumulator: (A, E) -> A, _ resultSelector: (A) -> R)
        -> Observable<R> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success(resultSelector($0)) })
    }

    public func reduce<A>
        (seed: A, _ accumulator: (A, E) -> A)
        -> Observable<A> {
        return Aggregate(source: self.normalize(), seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success($0) })
    }
}
