//
//  Observable+Creation.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

@available(*, deprecated=2.0.0, message="Please use `Observable.create`")
public func create<E>(subscribe: (AnyObserver<E>) -> Disposable) -> Observable<E> {
    return Observable.create(subscribe)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.empty`")
public func empty<E>(type: E.Type = E.self) -> Observable<E> {
    return Observable.empty()
}

@available(*, deprecated=2.0.0, message="Please use `Observable.never`")
public func never<E>(type: E.Type = E.self) -> Observable<E> {
    return Observable.never()
}

@available(*, deprecated=2.0.0, message="Please use `Observable.just`")
public func just<E>(element: E) -> Observable<E> {
    return Observable.just(element)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.just`")
public func just<E>(element: E, scheduler: ImmediateSchedulerType) -> Observable<E> {
    return Observable.just(element, scheduler: scheduler)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.error`")
public func failWith<E>(error: ErrorType, _ type: E.Type = E.self) -> Observable<E> {
    return Observable.error(error)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.of`")
public func sequenceOf<E>(elements: E ..., scheduler: ImmediateSchedulerType? = nil) -> Observable<E> {
    return Sequence(elements: elements, scheduler: scheduler)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.deferred`")
public func deferred<E>(observableFactory: () throws -> Observable<E>) -> Observable<E> {
    return Observable.deferred(observableFactory)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.generate` with named initialState parameter.")
public func generate<E>(initialState: E, condition: E throws -> Bool, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance, iterate: E throws -> E) -> Observable<E> {
    return Observable.generate(initialState: initialState, condition: condition, scheduler: scheduler, iterate: iterate)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.range` with named start, count, scheduler parameters.")
public func range(start: Int, _ count: Int, _ scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Int> {
    return Observable.range(start: start, count: count, scheduler: scheduler)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.repeatElement` with named scheduler parameter.")
public func repeatElement<E>(element: E, _ scheduler: ImmediateSchedulerType) -> Observable<E> {
    return Observable.repeatElement(element, scheduler: scheduler)
}

@available(*, deprecated=2.0.0, message="Please use `Observable.using`.")
public func using<S, R: Disposable>(resourceFactory: () throws -> R, observableFactory: R throws -> Observable<S>) -> Observable<S> {
    return Observable.using(resourceFactory, observableFactory: observableFactory)
}

extension Observable {
    // MARK: create

    /**
    Creates an observable sequence from a specified subscribe method implementation.

    - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

    - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
    - returns: The observable sequence with the specified implementation for the `subscribe` method.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func create(subscribe: (AnyObserver<E>) -> Disposable) -> Observable<E> {
        return AnonymousObservable(subscribe)
    }

    // MARK: empty

    /**
    Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

    - seealso: [empty operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

    - returns: An observable sequence with no elements.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func empty() -> Observable<E> {
        return Empty<E>()
    }

    // MARK: never

    /**
    Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

    - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

    - returns: An observable sequence whose observers will never get called.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func never() -> Observable<E> {
        return Never()
    }

    // MARK: just

    /**
    Returns an observable sequence that contains a single element.

    - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

    - parameter element: Single element in the resulting observable sequence.
    - returns: An observable sequence containing the single specified element.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func just(element: E) -> Observable<E> {
        return Just(element: element)
    }

    /**
    Returns an observable sequence that contains a single element.

    - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

    - parameter element: Single element in the resulting observable sequence.
    - parameter: Scheduler to send the single element on.
    - returns: An observable sequence containing the single specified element.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func just(element: E, scheduler: ImmediateSchedulerType) -> Observable<E> {
        return JustScheduled(element: element, scheduler: scheduler)
    }

    // MARK: fail

    /**
    Returns an observable sequence that terminates with an `error`.

    - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

    - returns: The observable sequence that terminates with specified error.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func error(error: ErrorType) -> Observable<E> {
        return Error(error: error)
    }

    // MARK: of

    /**
    This method creates a new Observable instance with a variable number of elements.

    - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

    - parameter elements: Elements to generate.
    - parameter scheduler: Scheduler to send elements on. If `nil`, elements are sent immediatelly on subscription.
    - returns: The observable sequence whose elements are pulled from the given arguments.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func of(elements: E ..., scheduler: ImmediateSchedulerType? = nil) -> Observable<E> {
        return Sequence(elements: elements, scheduler: scheduler)
    }

    // MARK: defer

    /**
    Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

    - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

    - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
    - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func deferred(observableFactory: () throws -> Observable<E>)
        -> Observable<E> {
        return Deferred(observableFactory: observableFactory)
    }

    /**
    Generates an observable sequence by running a state-driven loop producing the sequence's elements, using the specified scheduler
    to run the loop send out observer messages.

    - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

    - parameter initialState: Initial state.
    - parameter condition: Condition to terminate generation (upon returning `false`).
    - parameter iterate: Iteration step function.
    - parameter scheduler: Scheduler on which to run the generator loop.
    - returns: The generated sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func generate(initialState initialState: E, condition: E throws -> Bool, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance, iterate: E throws -> E) -> Observable<E> {
        return Generate(initialState: initialState, condition: condition, iterate: iterate, resultSelector: { $0 }, scheduler: scheduler)
    }

    /**
    Generates an observable sequence that repeats the given element infinitely, using the specified scheduler to send out observer messages.

    - seealso: [repeat operator on reactivex.io](http://reactivex.io/documentation/operators/repeat.html)

    - parameter element: Element to repeat.
    - parameter scheduler: Scheduler to run the producer loop on.
    - returns: An observable sequence that repeats the given element infinitely.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func repeatElement(element: E, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<E> {
        return RepeatElement(element: element, scheduler: scheduler)
    }

    /**
    Constructs an observable sequence that depends on a resource object, whose lifetime is tied to the resulting observable sequence's lifetime.

    - seealso: [using operator on reactivex.io](http://reactivex.io/documentation/operators/using.html)
     
    - parameter resourceFactory: Factory function to obtain a resource object.
    - parameter observableFactory: Factory function to obtain an observable sequence that depends on the obtained resource.
    - returns: An observable sequence whose lifetime controls the lifetime of the dependent resource object.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func using<R: Disposable>(resourceFactory: () throws -> R, observableFactory: R throws -> Observable<E>) -> Observable<E> {
        return Using(resourceFactory: resourceFactory, observableFactory: observableFactory)
    }
}

extension Observable where Element : SignedIntegerType {
    /**
    Generates an observable sequence of integral numbers within a specified range, using the specified scheduler to generate and send out observer messages.

    - seealso: [range operator on reactivex.io](http://reactivex.io/documentation/operators/range.html)

    - parameter start: The value of the first integer in the sequence.
    - parameter count: The number of sequential integers to generate.
    - parameter scheduler: Scheduler to run the generator loop on.
    - returns: An observable sequence that contains a range of sequential integral numbers.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func range(start start: E, count: E, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<E> {
        return RangeProducer<E>(start: start, count: count, scheduler: scheduler)
    }
}

extension SequenceType {
    /**
    Converts a sequence to an observable sequence.

    - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

    - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use toObservable extension.")
    public func asObservable() -> Observable<Generator.Element> {
        return Sequence(elements: Array(self), scheduler: nil)
    }

    /**
    Converts a sequence to an observable sequence.

    - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

    - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func toObservable(scheduler: ImmediateSchedulerType? = nil) -> Observable<Generator.Element> {
        return Sequence(elements: Array(self), scheduler: scheduler)
    }
}

extension Array {
    /**
    Converts a sequence to an observable sequence.

    - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

    - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func toObservable(scheduler: ImmediateSchedulerType? = nil) -> Observable<Generator.Element> {
        return Sequence(elements: self, scheduler: scheduler)
    }
}