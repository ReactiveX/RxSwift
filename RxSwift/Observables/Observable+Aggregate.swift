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
    
    /**
    Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.

    For aggregation behavior with incremental intermediate results, see `scan`.

    - parameter seed: The initial accumulator value.
    - parameter accumulator: A accumulator function to be invoked on each element.
    - parameter mapResult: A function to transform the final accumulator value into the result value.
    - returns: An observable sequence containing a single element with the final accumulator value.
    */
    public func reduce<A, R>(seed: A, _ accumulator: (A, E) throws -> A, mapResult: (A) throws -> R)
        -> Observable<R> {
        return Reduce(source: self.asObservable(), seed: seed, accumulator: accumulator, mapResult: mapResult)
    }
    
    /**
    Applies an `accumulator` function over an observable sequence, returning the result of the aggregation as a single element in the result sequence. The specified `seed` value is used as the initial accumulator value.
    
    For aggregation behavior with incremental intermediate results, see `scan`.
    
    - parameter seed: The initial accumulator value.
    - parameter accumulator: A accumulator function to be invoked on each element.
    - returns: An observable sequence containing a single element with the final accumulator value.
    */
    public func reduce<A>(seed: A, _ accumulator: (A, E) throws -> A)
        -> Observable<A> {
        return Reduce(source: self.asObservable(), seed: seed, accumulator: accumulator, mapResult: { $0 })
    }
}


// average

extension ObservableType where E == Int {

    /**
    Calculates the `average` over an observable Int sequence, returning the result as a single Double value.
    
    - returns: An observable sequence containing a single Double element with the average value.
    */
    public func average() -> Observable<Double> {
        let source = self.asObservable()
        typealias Acc = (Double, Int)
        return source.reduce(Acc(0, 0), { (acc: Acc, element: Int) -> Acc in
            Acc(acc.0 + Double(element), acc.1 + 1)
            })
            { (result: Acc) -> Double in
                result.0 / Double(result.1)
        }
    }
}

extension ObservableType where E == Float {

    /**
    Calculates the `average` over an observable Float sequence, returning the result as a single Float value.
    
    - returns: An observable sequence containing a single Float element with the average value.
    */
    public func average() -> Observable<Float> {
        let source = self.asObservable()
        typealias Acc = (Float, Int)
        return source.reduce(Acc(0, 0), { (acc: Acc, element: Float) -> Acc in
            Acc(acc.0 + element, acc.1 + 1)
            })
            { (result: Acc) -> Float in
                return result.0 / Float(result.1)
        }
    }
}

extension ObservableType where E == Double {

    /**
    Calculates the `average` over an observable Double sequence, returning the result as a single Double value.
    
    - returns: An observable sequence containing a single Double element with the average value.
    */
    public func average() -> Observable<Double> {
        let source = self.asObservable()
        typealias Acc = (Double, Double)
        return source.reduce(Acc(0, 0), { (acc: Acc, element: Double) -> Acc in
            Acc(acc.0 + element, acc.1 + 1)
            })
            { (result: Acc) -> Double in
                result.0 / result.1
        }
    }
}
