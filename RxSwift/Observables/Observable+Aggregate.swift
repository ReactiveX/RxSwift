//
//  Observable+Aggregate.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// reduce

extension ObservableType {
    public func reduce<A, R>(seed: A, _ accumulator: (A, E) throws -> A, mapResult: (A) throws -> R)
        -> Observable<R> {
        return Reduce(source: self.asObservable(), seed: seed, accumulator: accumulator, mapResult: mapResult)
    }
    
    public func reduce<A>(seed: A, _ accumulator: (A, E) throws -> A)
        -> Observable<A> {
        return Reduce(source: self.asObservable(), seed: seed, accumulator: accumulator, mapResult: { $0 })
    }
}
