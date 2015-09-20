//
//  Driver+Operators.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

extension Driver {
    
    /**
    Projects each element of an observable sequence into a new form.
    
    - parameter selector: A transform function to apply to each source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func map<R>(selector: E -> R) -> Driver<R> {
        let source = _source
            .map(selector)
        return Driver<R>(source)
    }
    
    /**
    Projects each element of an observable sequence into a new form by incorporating the element's index.
    
    - parameter selector: A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    public func mapWithIndex<R>(selector: (E, Int) -> R) -> Driver<R> {
        let source = _source
            .mapWithIndex(selector)
        return Driver<R>(source)
    }
   
    /**
    Filters the elements of an observable sequence based on a predicate.
    
    - parameter predicate: A function to test each source element for a condition.
    - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
    */
    public func filter(predicate: (E) -> Bool) -> Driver<E> {
        let source = _source
            .filter(predicate)
        return Driver(source)
    }
}

extension Driver where Element : DriverConvertibleType {
    
    /**
    Transforms an observable sequence of observable sequences into an observable sequence
    producing values only from the most recent observable sequence.
    
    Each time a new inner observable sequence is received, unsubscribe from the
    previous inner observable sequence.
    
    - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
    */
    public func switchLatest() -> Driver<E.E> {
        let source: Observable<E.E> = _source
            .map { $0.asDriver() }
            .switchLatest()
        return Driver<E.E>(source)
    }
}

extension Driver {
    
    /**
    Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
    
    - parameter eventHandler: Action to invoke for each event in the observable sequence.
    - returns: The source sequence with the side-effecting behavior applied.
    */
    public func doOn(eventHandler: (Event<E>) -> Void)
        -> Driver<E> {
        let source = _source
                .doOn(eventHandler)
        
        return Driver(source)
    }
    
    /**
    Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - parameter onError: Action to invoke upon errored termination of the observable sequence.
    - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
    - returns: The source sequence with the side-effecting behavior applied.
    */
    public func doOn(onNext onNext: (E -> Void)? = nil, onError: (ErrorType -> Void)? = nil, onCompleted: (() -> Void)? = nil)
        -> Driver<E> {
        let source = _source
            .doOn(onNext: onNext, onError: onError, onCompleted: onCompleted)
            
        return Driver(source)
    }
}

extension Driver {
    
    /**
    Prints received events for all observers on standard output.
    
    - parameter identifier: Identifier that is printed together with event description to standard output.
    - returns: An observable sequence whose events are printed to standard output.
    */
    public func debug(identifier: String = "\(__FILE__):\(__LINE__)") -> Driver<E> {
        let source = _source
            .debug(identifier)
        return Driver(source)
    }
}

extension Driver where Element: Equatable {
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to equality operator.
    
    - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
    */
    public func distinctUntilChanged()
        -> Driver<E> {
        let source = _source
            .self.distinctUntilChanged({ $0 }, comparer: { ($0 == $1) })
            
        return Driver(source)
    }
}

extension Driver {
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the `keySelector`.
    
    - parameter keySelector: A function to compute the comparison key for each element.
    - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value, from the source sequence.
    */
    public func distinctUntilChanged<K: Equatable>(keySelector: (E) -> K) -> Driver<E> {
        let source = _source
            .distinctUntilChanged(keySelector, comparer: { $0 == $1 })
        return Driver(source)
    }
   
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.
    
    - parameter comparer: Equality comparer for computed key values.
    - returns: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
    */
    public func distinctUntilChanged(comparer: (lhs: E, rhs: E) -> Bool) -> Driver<E> {
        let source = _source
            .distinctUntilChanged({ $0 }, comparer: comparer)
        return Driver(source)
    }
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the keySelector and the comparer.
    
    - parameter keySelector: A function to compute the comparison key for each element.
    - parameter comparer: Equality comparer for computed key values.
    - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value and the comparer, from the source sequence.
    */
    public func distinctUntilChanged<K>(keySelector: (E) -> K, comparer: (lhs: K, rhs: K) -> Bool) -> Driver<E> {
        let source = _source
            .distinctUntilChanged(keySelector, comparer: comparer)
        return Driver(source)
    }
}


extension Driver {
    
    /**
    Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    public func flatMap<R>(selector: (E) -> Driver<R>) -> Driver<R> {
        let source = _source
            .flatMap(selector)
        
        return Driver<R>(source)
    }
    
    /**
    Projects each element of an observable sequence to an observable sequence by incorporating the element's index and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element; the second parameter of the function represents the index of the source element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    public func flatMapWithIndex<R>(selector: (E, Int) -> Driver<R>)
        -> Driver<R> {
        let source = _source
            .flatMapWithIndex(selector)
        
        return Driver<R>(source.asObservable())
    }
}

// merge
extension Driver where Element : DriverConvertibleType {
    
    /**
    Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.
    
    - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
    - returns: The observable sequence that merges the elements of the observable sequences.
    */
    public func merge() -> Driver<E.E> {
        let source = _source
            .map { $0.asDriver() }
            .merge()
        return Driver<E.E>(source)
    }
    
    /**
    Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.
    
    - returns: The observable sequence that merges the elements of the inner sequences.
    */
    public func merge(maxConcurrent maxConcurrent: Int)
        -> Driver<E.E> {
        let source = _source
            .map { $0.asDriver() }
            .merge(maxConcurrent: maxConcurrent)
        return Driver<E.E>(source)
    }
}

// throttle
extension Driver {
    
    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
    
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - parameter scheduler: Scheduler to run the throttle timers and send events on.
    - returns: The throttled sequence.
    */
    public func throttle<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Driver<E> {
        let source = _source
            .throttle(dueTime, scheduler)

        return Driver(source)
    }
    
    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
    
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - parameter scheduler: Scheduler to run the throttle timers and send events on.
    - returns: The throttled sequence.
    */
    public func debounce<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Driver<E> {
        let source = _source
            .debounce(dueTime, scheduler)

        return Driver(source)
    }
}

// scan
extension Driver {
    /**
    Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.
    
    For aggregation behavior with no intermediate results, see `reduce`.
    
    - parameter seed: The initial accumulator value.
    - parameter accumulator: An accumulator function to be invoked on each element.
    - returns: An observable sequence containing the accumulated values.
    */
    public func scan<A>(seed: A, accumulator: (A, E) -> A)
        -> Driver<A> {
        let source = _source
            .scan(seed, accumulator: accumulator)
        return Driver<A>(source)
    }
}