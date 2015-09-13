//
//  Observable+Creation.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// create

/**
Creates an observable sequence from a specified subscribe method implementation.

- parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
- returns: The observable sequence with the specified implementation for the `subscribe` method.
*/
public func create<E>(subscribe: (ObserverOf<E>) -> Disposable) -> Observable<E> {
    return AnonymousObservable(subscribe)
}

// empty

/**
Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

- returns: An observable sequence with no elements.
*/
public func empty<E>() -> Observable<E> {
    return Empty<E>()
}

// never

/**
Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

- returns: An observable sequence whose observers will never get called.
*/
public func never<E>() -> Observable<E> {
    return Never()
}

// just

/**
Returns an observable sequence that contains a single element.

- parameter element: Single element in the resulting observable sequence.
- returns: An observable sequence containing the single specified element.
*/
public func just<E>(element: E) -> Observable<E> {
    return Just(element: element)
}

// of

/**
This method creates a new Observable instance with a variable number of elements.

- returns: The observable sequence whose elements are pulled from the given arguments.
*/
public func sequenceOf<E>(elements: E ...) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in elements {
            observer.on(.Next(element))
        }
        
        observer.on(.Completed)
        return NopDisposable.instance
    }
}


extension SequenceType {
    /**
    Converts a sequence to an observable sequence.

    - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
    */
    public func asObservable() -> Observable<Generator.Element> {
        return AnonymousObservable { observer in
            for element in self {
                observer.on(.Next(element))
            }
            
            observer.on(.Completed)
            return NopDisposable.instance
        }
    }
}

// fail

/**
Returns an observable sequence that terminates with an `error`.

- returns: The observable sequence that terminates with specified error.
*/
public func failWith<E>(error: ErrorType) -> Observable<E> {
    return FailWith(error: error)
}

// defer

/**
Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

- parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
- returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
*/
public func deferred<E>(observableFactory: () throws -> Observable<E>)
    -> Observable<E> {
    return Deferred(observableFactory: observableFactory)
}

/**
Generates an observable sequence by running a state-driven loop producing the sequence's elements, using the specified scheduler 
to run the loop send out observer messages.

- parameter initialState: Initial state.
- parameter condition: Condition to terminate generation (upon returning `false`).
- parameter iterate: Iteration step function.
- parameter scheduler: Scheduler on which to run the generator loop.
- returns: The generated sequence.
*/
public func generate<E>(initialState: E, condition: E throws -> Bool, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance, iterate: E throws -> E) -> Observable<E> {
    return Generate(initialState: initialState, condition: condition, iterate: iterate, resultSelector: { $0 }, scheduler: scheduler)
}

/**
Generates an observable sequence of integral numbers within a specified range, using the specified scheduler to generate and send out observer messages.

- parameter start: The value of the first integer in the sequence.
- parameter count: The number of sequential integers to generate.
- parameter scheduler: Scheduler to run the generator loop on.
- returns: An observable sequence that contains a range of sequential integral numbers.
*/
public func range(start: Int, _ count: Int, _ scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance) -> Observable<Int> {
    if count < 0 {
        rxFatalError("count can't be negative")
    }

    if start &+ (count - 1) < start {
        rxFatalError("overflow of count")
    }
    
    return RangeProducer<Int>(start: start, count: count, scheduler: scheduler)
}

/**
Generates an observable sequence that repeats the given element infinitely, using the specified scheduler to send out observer messages.

- parameter element: Element to repeat.
- parameter scheduler: Scheduler to run the producer loop on.
- returns: An observable sequence that repeats the given element infinitely.
*/
public func repeatElement<E>(element: E, _ scheduler: ImmediateSchedulerType) -> Observable<E> {
    return RepeatElement(element: element, scheduler: scheduler)
}
