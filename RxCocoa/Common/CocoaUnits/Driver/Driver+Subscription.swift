//
//  Driver+Subscription.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

private let driverErrorMessage = "`drive*` family of methods can be only called from `MainThread`.\n" +
"This is required to ensure that the last replayed `Driver` element is delivered on `MainThread`.\n"

extension DriverConvertibleType {
    /**
    Creates new subscription and sends elements to observer.
    This method can be only called from `MainThread`.

    In this form it's equivalent to `subscribe` method, but it communicates intent better.

    - parameter observer: Observer that receives events.
    - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func drive<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        MainScheduler.ensureExecutingOnScheduler(driverErrorMessage)
        return self.asObservable().subscribe(observer)
    }

    /**
    Creates new subscription and sends elements to variable.
    This method can be only called from `MainThread`.

    - parameter variable: Target variable for sequence elements.
    - returns: Disposable object that can be used to unsubscribe the observer from the variable.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func drive(variable: Variable<E>) -> Disposable {
        MainScheduler.ensureExecutingOnScheduler(driverErrorMessage)
        return drive(onNext: { e in
            variable.value = e
        })
    }

    /**
    Subscribes to observable sequence using custom binder function.
    This method can be only called from `MainThread`.

    - parameter with: Function used to bind elements from `self`.
    - returns: Object representing subscription.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func drive<R>(transformation: Observable<E> -> R) -> R {
        MainScheduler.ensureExecutingOnScheduler(driverErrorMessage)
        return transformation(self.asObservable())
    }

    /**
    Subscribes to observable sequence using custom binder function and final parameter passed to binder function
    after `self` is passed.

        public func drive<R1, R2>(with: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
            return with(self)(curriedArgument)
        }

    This method can be only called from `MainThread`.

    - parameter with: Function used to bind elements from `self`.
    - parameter curriedArgument: Final argument passed to `binder` to finish binding process.
    - returns: Object representing subscription.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func drive<R1, R2>(with: Observable<E> -> R1 -> R2, curriedArgument: R1) -> R2 {
        MainScheduler.ensureExecutingOnScheduler(driverErrorMessage)
        return with(self.asObservable())(curriedArgument)
    }
    
    /**
    Subscribes an element handler, a completion handler and disposed handler to an observable sequence.
    This method can be only called from `MainThread`.
    
    Error callback is not exposed because `Driver` can't error out.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
    gracefully completed, errored, or if the generation is cancelled by disposing subscription)
    - parameter onDisposed: Action to invoke upon any type of termination of sequence (if the sequence has
    gracefully completed, errored, or if the generation is cancelled by disposing subscription)
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func drive(onNext onNext: ((E) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil) -> Disposable {
        MainScheduler.ensureExecutingOnScheduler(driverErrorMessage)
        return self.asObservable().subscribe(onNext: onNext, onCompleted: onCompleted, onDisposed: onDisposed)
    }
    
    /**
    Subscribes an element handler to an observable sequence.
    This method can be only called from `MainThread`.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func driveNext(onNext: E -> Void) -> Disposable {
        MainScheduler.ensureExecutingOnScheduler(driverErrorMessage)
        return self.asObservable().subscribeNext(onNext)
    }
}


