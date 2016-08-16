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

// MARK: map
extension DriverConvertibleType {
    
    /**
    Projects each element of an observable sequence into a new form.
    
    - parameter selector: A transform function to apply to each source element.
    - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func map<R>(_ selector: @escaping (E) -> R) -> Driver<R> {
        let source = self
            .asObservable()
            .map(selector)
        return Driver<R>(source)
    }
}

// MARK: filter
extension DriverConvertibleType {
    /**
    Filters the elements of an observable sequence based on a predicate.
    
    - parameter predicate: A function to test each source element for a condition.
    - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func filter(_ predicate: @escaping (E) -> Bool) -> Driver<E> {
        let source = self
            .asObservable()
            .filter(predicate)
        return Driver(source)
    }
}

// MARK: switchLatest
extension DriverConvertibleType where E : DriverConvertibleType {
    
    /**
    Transforms an observable sequence of observable sequences into an observable sequence
    producing values only from the most recent observable sequence.
    
    Each time a new inner observable sequence is received, unsubscribe from the
    previous inner observable sequence.
    
    - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func switchLatest() -> Driver<E.E> {
        let source: Observable<E.E> = self
            .asObservable()
            .map { $0.asDriver() }
            .switchLatest()
        return Driver<E.E>(source)
    }
}

// MARK: flatMapLatest
extension DriverConvertibleType {
    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func flatMapLatest<R>(_ selector: @escaping (E) -> Driver<R>)
        -> Driver<R> {
        let source: Observable<R> = self
            .asObservable()
            .flatMapLatest(selector)
        return Driver<R>(source)
    }
}

// MARK: flatMapFirst
extension DriverConvertibleType {

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     If element is received while there is some projected observable sequence being merged it will simply be ignored.

     - parameter selector: A transform function to apply to element that was observed while no observable is executing in parallel.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
     */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func flatMapFirst<R>(_ selector: @escaping (E) -> Driver<R>)
        -> Driver<R> {
        let source: Observable<R> = self
            .asObservable()
            .flatMapFirst(selector)
        return Driver<R>(source)
    }
}

// MARK: doOn
extension DriverConvertibleType {
    
    /**
    Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
    
    - parameter eventHandler: Action to invoke for each event in the observable sequence.
    - returns: The source sequence with the side-effecting behavior applied.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    @available(*, deprecated, renamed: "do(onNext:onError:onCompleted:)")
    public func doOn(_ eventHandler: @escaping (Event<E>) -> Void)
        -> Driver<E> {
        let source = self.asObservable()
            .doOn(eventHandler)
        
        return Driver(source)
    }
    
    /**
    Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - parameter onError: Action to invoke upon errored termination of the observable sequence. This callback will never be invoked since driver can't error out.
    - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
    - returns: The source sequence with the side-effecting behavior applied.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    @available(*, deprecated, renamed: "do(onNext:onError:onCompleted:)")
    public func doOn(onNext: ((E) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil)
        -> Driver<E> {
        let source = self.asObservable()
            .doOn(onNext: onNext, onError: onError, onCompleted: onCompleted)
            
        return Driver(source)
    }

    /**
     Invokes an action for each Next event in the observable sequence, and propagates all observer messages through the result sequence.

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    @available(*, deprecated, renamed: "do(onNext:)")
    public func doOnNext(_ onNext: @escaping (E) -> Void)
        -> Driver<E> {
            return self.do(onNext: onNext)
    }

    /**
     Invokes an action for the Completed event in the observable sequence, and propagates all observer messages through the result sequence.

     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    @available(*, deprecated, renamed: "do(onCompleted:)")
    public func doOnCompleted(_ onCompleted: @escaping () -> Void)
        -> Driver<E> {
            return self.do(onCompleted: onCompleted)
    }

    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence. This callback will never be invoked since driver can't error out.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func `do`(onNext: ((E) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onSubscribe: (() -> ())? = nil, onDispose: (() -> ())? = nil)
        -> Driver<E> {
        let source = self.asObservable()
            .do(onNext: onNext, onError: onError, onCompleted: onCompleted, onSubscribe: onSubscribe, onDispose: onDispose)

        return Driver(source)
    }
}

// MARK: debug
extension DriverConvertibleType {
    
    /**
    Prints received events for all observers on standard output.
    
    - parameter identifier: Identifier that is printed together with event description to standard output.
    - returns: An observable sequence whose events are printed to standard output.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func debug(_ identifier: String? = nil, file: String = #file, line: UInt = #line, function: String = #function) -> Driver<E> {
        let source = self.asObservable()
            .debug(identifier, file: file, line: line, function: function)
        return Driver(source)
    }
}

// MARK: distinctUntilChanged
extension DriverConvertibleType where E: Equatable {
    
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to equality operator.
    
    - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
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
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func distinctUntilChanged<K: Equatable>(_ keySelector: @escaping (E) -> K) -> Driver<E> {
        let source = self.asObservable()
            .distinctUntilChanged(keySelector, comparer: { $0 == $1 })
        return Driver(source)
    }
   
    /**
    Returns an observable sequence that contains only distinct contiguous elements according to the `comparer`.
    
    - parameter comparer: Equality comparer for computed key values.
    - returns: An observable sequence only containing the distinct contiguous elements, based on `comparer`, from the source sequence.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func distinctUntilChanged(_ comparer: @escaping (E, E) -> Bool) -> Driver<E> {
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
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func distinctUntilChanged<K>(_ keySelector: @escaping (E) -> K, comparer: @escaping (K, K) -> Bool) -> Driver<E> {
        let source = self.asObservable()
            .distinctUntilChanged(keySelector, comparer: comparer)
        return Driver(source)
    }
}


// MARK: flatMap
extension DriverConvertibleType {
    
    /**
    Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
    
    - parameter selector: A transform function to apply to each element.
    - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func flatMap<R>(_ selector: @escaping (E) -> Driver<R>) -> Driver<R> {
        let source = self.asObservable()
            .flatMap(selector)
        
        return Driver<R>(source)
    }
}

// MARK: merge
extension DriverConvertibleType where E : DriverConvertibleType {
    
    /**
    Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.
    
    - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
    - returns: The observable sequence that merges the elements of the observable sequences.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
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
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func merge(maxConcurrent: Int)
        -> Driver<E.E> {
        let source = self.asObservable()
            .map { $0.asDriver() }
            .merge(maxConcurrent: maxConcurrent)
        return Driver<E.E>(source)
    }
}

// MARK: throttle
extension DriverConvertibleType {
    
    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
    
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - returns: The throttled sequence.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func throttle(_ dueTime: RxTimeInterval)
        -> Driver<E> {
        let source = self.asObservable()
            .throttle(dueTime, scheduler: driverObserveOnScheduler)

        return Driver(source)
    }

    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
    
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - returns: The throttled sequence.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func debounce(_ dueTime: RxTimeInterval)
        -> Driver<E> {
        let source = self.asObservable()
            .debounce(dueTime, scheduler: driverObserveOnScheduler)

        return Driver(source)
    }
}

// MARK: scan
extension DriverConvertibleType {
    /**
    Applies an accumulator function over an observable sequence and returns each intermediate result. The specified seed value is used as the initial accumulator value.
    
    For aggregation behavior with no intermediate results, see `reduce`.
    
    - parameter seed: The initial accumulator value.
    - parameter accumulator: An accumulator function to be invoked on each element.
    - returns: An observable sequence containing the accumulated values.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func scan<A>(_ seed: A, accumulator: @escaping (A, E) -> A)
        -> Driver<A> {
        let source = self.asObservable()
            .scan(seed, accumulator: accumulator)
        return Driver<A>(source)
    }
}

// MARK: concat
extension Sequence where Iterator.Element : DriverConvertibleType {

    /**
    Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

    - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func concat()
        -> Driver<Iterator.Element.E> {
        let source = self.lazy.map { $0.asDriver().asObservable() }.concat()
        return Driver<Iterator.Element.E>(source)
    }
}

extension Collection where Iterator.Element : DriverConvertibleType {

    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func concat()
        -> Driver<Generator.Element.E> {
        let source = self.map { $0.asDriver().asObservable() }.concat()
        return Driver<Generator.Element.E>(source)
    }
}

// MARK: zip
extension Collection where Iterator.Element : DriverConvertibleType {

    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func zip<R>(_ resultSelector: @escaping ([Generator.Element.E]) throws -> R) -> Driver<R> {
        let source = self.map { $0.asDriver().asObservable() }.zip(resultSelector)
        return Driver<R>(source)
    }
}

// MARK: combineLatest
extension Collection where Iterator.Element : DriverConvertibleType {

    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

    - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func combineLatest<R>(_ resultSelector: @escaping ([Generator.Element.E]) throws -> R) -> Driver<R> {
        let source = self.map { $0.asDriver().asObservable() }.combineLatest(resultSelector)
        return Driver<R>(source)
    }
}

// MARK: withLatestFrom
extension DriverConvertibleType {

    /**
    Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.

    - parameter second: Second observable source.
    - parameter resultSelector: Function to invoke for each element from the self combined with the latest element from the second source, if any.
    - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
    */
    public func withLatestFrom<SecondO: DriverConvertibleType, ResultType>(_ second: SecondO, resultSelector: @escaping (E, SecondO.E) -> ResultType) -> Driver<ResultType> {
        let source = self.asObservable()
            .withLatestFrom(second.asDriver(), resultSelector: resultSelector)

        return Driver<ResultType>(source)
    }

    /**
    Merges two observable sequences into one observable sequence by using latest element from the second sequence every time when `self` emitts an element.

    - parameter second: Second observable source.
    - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
    */
    public func withLatestFrom<SecondO: DriverConvertibleType>(_ second: SecondO) -> Driver<SecondO.E> {
        let source = self.asObservable()
            .withLatestFrom(second.asDriver())

        return Driver<SecondO.E>(source)
    }
}

// MARK: skip
extension DriverConvertibleType {

    /**
     Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.

     - seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)

     - parameter count: The number of elements to skip before returning the remaining elements.
     - returns: An observable sequence that contains the elements that occur after the specified index in the input sequence.
     */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func skip(_ count: Int)
        -> Driver<E> {
        let source = self.asObservable()
            .skip(count)
        return Driver(source)
    }
}

// MARK: startWith
extension DriverConvertibleType {
    
    /**
    Prepends a value to an observable sequence.

    - seealso: [startWith operator on reactivex.io](http://reactivex.io/documentation/operators/startwith.html)
    
    - parameter element: Element to prepend to the specified sequence.
    - returns: The source sequence prepended with the specified values.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func startWith(_ element: E)
        -> Driver<E> {
        let source = self.asObservable()
                .startWith(element)

        return Driver(source)
    }
}
