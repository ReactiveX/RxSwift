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

extension DriverConvertibleType {
    
    /**
    Projects each element of an observable sequence into a new form.
    
    - parameter selector: A transform function to apply to each source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func map<R>(selector: E -> R) -> Driver<R> {
        let source = self
            .asObservable()
            .map(selector)
        return Driver<R>(source)
    }
    
    /**
    Filters the elements of an observable sequence based on a predicate.
    
    - parameter predicate: A function to test each source element for a condition.
    - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func filter(predicate: (E) -> Bool) -> Driver<E> {
        let source = self
            .asObservable()
            .filter(predicate)
        return Driver(source)
    }
}

extension DriverConvertibleType where E : DriverConvertibleType {
    
    /**
    Transforms an observable sequence of observable sequences into an observable sequence
    producing values only from the most recent observable sequence.
    
    Each time a new inner observable sequence is received, unsubscribe from the
    previous inner observable sequence.
    
    - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func switchLatest() -> Driver<E.E> {
        let source: Observable<E.E> = self
            .asObservable()
            .map { $0.asDriver() }
            .switchLatest()
        return Driver<E.E>(source)
    }
}

extension DriverConvertibleType {
    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func flatMapLatest<R>(selector: (E) -> Driver<R>)
        -> Driver<R> {
        let source: Observable<R> = self
            .asObservable()
            .flatMapLatest(selector)
        return Driver<R>(source)
    }
}

extension DriverConvertibleType {
    
    /**
    Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
    
    - parameter eventHandler: Action to invoke for each event in the observable sequence.
    - returns: The source sequence with the side-effecting behavior applied.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOn(eventHandler: (Event<E>) -> Void)
        -> Driver<E> {
        let source = self.asObservable()
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
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func doOn(onNext onNext: (E -> Void)? = nil, onError: (ErrorType -> Void)? = nil, onCompleted: (() -> Void)? = nil)
        -> Driver<E> {
        let source = self.asObservable()
            .doOn(onNext: onNext, onError: onError, onCompleted: onCompleted)
            
        return Driver(source)
    }
}

extension DriverConvertibleType {
    
    /**
    Prints received events for all observers on standard output.
    
    - parameter identifier: Identifier that is printed together with event description to standard output.
    - returns: An observable sequence whose events are printed to standard output.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func debug(identifier: String = "\(__FILE__):\(__LINE__)") -> Driver<E> {
        let source = self.asObservable()
            .debug(identifier)
        return Driver(source)
    }
}

extension DriverConvertibleType where E: Equatable {
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to equality operator.
    
    - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged()
        -> Driver<E> {
        let source = self.asObservable()
            .distinctUntilChanged({ $0 }, comparer: { ($0 == $1) })
            
        return Driver(source)
    }
}

extension DriverConvertibleType {
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the `keySelector`.
    
    - parameter keySelector: A function to compute the comparison key for each element.
    - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged<K: Equatable>(keySelector: (E) -> K) -> Driver<E> {
        let source = self.asObservable()
            .distinctUntilChanged(keySelector, comparer: { $0 == $1 })
        return Driver(source)
    }
   
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.
    
    - parameter comparer: Equality comparer for computed key values.
    - returns: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged(comparer: (lhs: E, rhs: E) -> Bool) -> Driver<E> {
        let source = self.asObservable()
            .distinctUntilChanged({ $0 }, comparer: comparer)
        return Driver(source)
    }
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the keySelector and the comparer.
    
    - parameter keySelector: A function to compute the comparison key for each element.
    - parameter comparer: Equality comparer for computed key values.
    - returns: An observable sequence only containing the distinct contiguous elements, based on a computed key value and the comparer, from the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func distinctUntilChanged<K>(keySelector: (E) -> K, comparer: (lhs: K, rhs: K) -> Bool) -> Driver<E> {
        let source = self.asObservable()
            .distinctUntilChanged(keySelector, comparer: comparer)
        return Driver(source)
    }
}


extension DriverConvertibleType {
    
    /**
    Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func flatMap<R>(selector: (E) -> Driver<R>) -> Driver<R> {
        let source = self.asObservable()
            .flatMap(selector)
        
        return Driver<R>(source)
    }
}

// merge
extension DriverConvertibleType where E : DriverConvertibleType {
    
    /**
    Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.
    
    - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
    - returns: The observable sequence that merges the elements of the observable sequences.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func merge() -> Driver<E.E> {
        let source = self.asObservable()
            .map { $0.asDriver() }
            .merge()
        return Driver<E.E>(source)
    }
    
    /**
    Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.
    
    - returns: The observable sequence that merges the elements of the inner sequences.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func merge(maxConcurrent maxConcurrent: Int)
        -> Driver<E.E> {
        let source = self.asObservable()
            .map { $0.asDriver() }
            .merge(maxConcurrent: maxConcurrent)
        return Driver<E.E>(source)
    }
}

// throttle
extension DriverConvertibleType {
    
    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
    
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - parameter scheduler: Scheduler to run the throttle timers and send events on.
    - returns: The throttled sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func throttle<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Driver<E> {
        let source = self.asObservable()
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
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func debounce<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Driver<E> {
        let source = self.asObservable()
            .debounce(dueTime, scheduler)

        return Driver(source)
    }
}

// scan
extension DriverConvertibleType {
    /**
    Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.
    
    For aggregation behavior with no intermediate results, see `reduce`.
    
    - parameter seed: The initial accumulator value.
    - parameter accumulator: An accumulator function to be invoked on each element.
    - returns: An observable sequence containing the accumulated values.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func scan<A>(seed: A, accumulator: (A, E) -> A)
        -> Driver<A> {
        let source = self.asObservable()
            .scan(seed, accumulator: accumulator)
        return Driver<A>(source)
    }
}

extension SequenceType where Generator.Element : DriverConvertibleType {

    /**
    Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

    - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func concat()
        -> Driver<Generator.Element.E> {
        let source: Observable<Generator.Element.E> = self.lazy.map { $0.asDriver() }.concat()
        return Driver<Generator.Element.E>(source)
    }
}

extension CollectionType where Generator.Element : DriverConvertibleType {

    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func zip<R>(resultSelector: [Generator.Element.E] throws -> R) -> Driver<R> {
        let source: Observable<R> = self.map { $0.asDriver() }.zip(resultSelector)
        return Driver<R>(source)
    }
}

extension CollectionType where Generator.Element : DriverConvertibleType {

    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

    - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func combineLatest<R>(resultSelector: [Generator.Element.E] throws -> R) -> Driver<R> {
        let source : Observable<R> = self.map { $0.asDriver() }.combineLatest(resultSelector)
        return Driver<R>(source)
    }
}

extension DriverConvertibleType {

    /**
    Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.

    - parameter second: Second observable source.
    - parameter resultSelector: Function to invoke for each element from the self combined with the latest element from the second source, if any.
    - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
    */
    public func withLatestFrom<SecondO: DriverConvertibleType, ResultType>(second: SecondO, resultSelector: (E, SecondO.E) -> ResultType) -> Driver<ResultType> {
        let source = self.asObservable()
            .withLatestFrom(second.asDriver(), resultSelector: resultSelector)

        return Driver<ResultType>(source)
    }

    /**
    Merges two observable sequences into one observable sequence by using latest element from the second sequence every time when `self` emitts an element.

    - parameter second: Second observable source.
    - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
    */
    public func withLatestFrom<SecondO: DriverConvertibleType>(second: SecondO) -> Driver<SecondO.E> {
        let source = self.asObservable()
            .withLatestFrom(second.asDriver())

        return Driver<SecondO.E>(source)
    }
}