//
//  Observable+Aggregate.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// aggregate

public func aggregateOrDie<E, A, R>
    (seed: A, accumulator: (A, E) -> Result<A>, resultSelector: (A) -> Result<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: accumulator, resultSelector: resultSelector)
    }
}

public func aggregateOrDie<E, A>
    (seed: A, accumulator: (A, E) -> Result<A>)
    -> (Observable<E> -> Observable<A>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: accumulator, resultSelector: { success($0) })
    }
}

public func aggregate<E, A, R>
    (seed: A, accumulator: (A, E) -> A, resultSelector: (A) -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success(resultSelector($0)) })
    }
}

public func aggregate<E, A>
    (seed: A, accumulator: (A, E) -> A)
    -> (Observable<E> -> Observable<A>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success($0) })
    }
}

// foldl

public func foldlOrDie<E, A, R>
    (seed: A, accumulator: (A, E) -> Result<A>, resultSelector: (A) -> Result<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: accumulator, resultSelector: resultSelector)
    }
}

public func foldlOrDie<E, A>
    (seed: A, accumulator: (A, E) -> Result<A>)
    -> (Observable<E> -> Observable<A>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: accumulator, resultSelector: { success($0) })
    }
}

public func foldl<E, A, R>
    (seed: A, accumulator: (A, E) -> A, resultSelector: (A) -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success(resultSelector($0)) })
    }
}

public func foldl<E, A>
    (seed: A, accumulator: (A, E) -> A)
    -> (Observable<E> -> Observable<A>) {
    return { source in
        return Aggregate(source: source, seed: seed, accumulator: { success(accumulator($0, $1)) }, resultSelector: { success($0) })
    }
}