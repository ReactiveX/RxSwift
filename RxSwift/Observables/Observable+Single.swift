//
//  Observable+Single.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// MARK: distinct until changed

extension ObservableType where E: Equatable {
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to equality operator.
    
    - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged()
        -> Observable<E> {
        return self.distinctUntilChanged({ $0 }, comparer: { ($0 == $1) })
    }
}

extension ObservableType {
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the `keySelector`.
    
    - parameter keySelector: A function to compute the comparison key for each element.
    - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged<K: Equatable>(keySelector: (E) throws -> K)
        -> Observable<E> {
        return self.distinctUntilChanged(keySelector, comparer: { $0 == $1 })
    }

    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.
    
    - parameter comparer: Equality comparer for computed key values.
    - returns: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged(comparer: (lhs: E, rhs: E) throws -> Bool)
        -> Observable<E> {
        return self.distinctUntilChanged({ $0 }, comparer: comparer)
    }
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the keySelector and the comparer.
    
    - parameter keySelector: A function to compute the comparison key for each element.
    - parameter comparer: Equality comparer for computed key values.
    - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value and the comparer, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged<K>(keySelector: (E) throws -> K, comparer: (lhs: K, rhs: K) throws -> Bool)
        -> Observable<E> {
        return DistinctUntilChanged(source: self.asObservable(), selector: keySelector, comparer: comparer)
    }
}

// MARK: do

extension ObservableType {
    
    /**
    Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
    
    - parameter eventHandler: Action to invoke for each event in the observable sequence.
    - returns: The source sequence with the side-effecting behavior applied.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOn(eventHandler: (Event<E>) throws -> Void)
        -> Observable<E> {
        return Do(source: self.asObservable(), eventHandler: eventHandler)
    }

    /**
    Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - parameter onError: Action to invoke upon errored termination of the observable sequence.
    - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
    - returns: The source sequence with the side-effecting behavior applied.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOn(onNext onNext: (E throws -> Void)? = nil, onError: (ErrorType throws -> Void)? = nil, onCompleted: (() throws -> Void)? = nil)
        -> Observable<E> {
        return Do(source: self.asObservable()) { e in
            switch e {
            case .Next(let element):
                try onNext?(element)
            case .Error(let e):
                try onError?(e)
            case .Completed:
                try onCompleted?()
            }
        }
    }
}

// MARK: startWith

extension ObservableType {
    
    /**
    Prepends a sequence of values to an observable sequence.
    
    - parameter elements: Elements to prepend to the specified sequence.
    - returns: The source sequence prepended with the specified values.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func startWith(elements: E ...)
        -> Observable<E> {
        return StartWith(source: self.asObservable(), elements: elements)
    }
}

// MARK: retry

extension ObservableType {
    
    /**
    Repeats the source observable sequence until it successfully terminates.
    
    **This could potentially create an infinite sequence.**
    
    - returns: Observable sequence to repeat until it successfully terminates.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func retry() -> Observable<E> {
        return CatchSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()))
    }

    /**
    Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.
    
    If you encounter an error and want it to retry once, then you must use `retry(2)`

    - parameter maxAttemptCount: Maximum number of times to repeat the sequence.
    - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func retry(maxAttemptCount: Int)
        -> Observable<E> {
        return CatchSequence(sources: Repeat(count: maxAttemptCount, repeatedValue: self.asObservable()))
    }
    
    /**
    Repeats the source observable sequence on error when the notifier emits a next value.
    If the source observable errors and the notifier completes, it will complete the source sequence.
    
    - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
    - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func retryWhen<TriggerObservable: ObservableType, Error: ErrorType>(notificationHandler: Observable<Error> -> TriggerObservable)
        -> Observable<E> {
            return RetryWhenSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()), notificationHandler: notificationHandler)
    }

    /**
    Repeats the source observable sequence on error when the notifier emits a next value.
    If the source observable errors and the notifier completes, it will complete the source sequence.
    
    - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
    - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func retryWhen<TriggerObservable: ObservableType>(notificationHandler: Observable<ErrorType> -> TriggerObservable)
        -> Observable<E> {
            return RetryWhenSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()), notificationHandler: notificationHandler)
    }
}

// MARK: scan

extension ObservableType {
    
    /**
    Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.
    
    For aggregation behavior with no intermediate results, see `reduce`.
    
    - parameter seed: The initial accumulator value.
    - parameter accumulator: An accumulator function to be invoked on each element.
    - returns: An observable sequence containing the accumulated values.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func scan<A>(seed: A, accumulator: (A, E) throws -> A)
        -> Observable<A> {
        return Scan(source: self.asObservable(), seed: seed, accumulator: accumulator)
    }
}