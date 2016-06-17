//
//  Driver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

/**
A type that can be converted to `Driver`.
*/
public protocol DriverConvertibleType : ObservableConvertibleType {

    /**
    Converts self to `Driver`.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    func asDriver() -> Driver<E>
}

extension DriverConvertibleType {
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return asDriver().asObservable()
    }
}

/**
    Unit that represents observable sequence with following properties:

    - it never fails
    - it delivers events on `MainScheduler.instance`
    - `shareReplayLatestWhileConnected()` behavior
        - all observers share sequence computation resources
        - it's stateful, upon subscription (calling subscribe) last element is immediatelly replayed if it was produced
        - computation of elements is reference counted with respect to the number of observers
        - if there are no subscribers, it will release sequence computation resources

    `Driver<Element>` can be considered a builder pattern for observable sequences that drive the application.

    If observable sequence has produced at least one element, after new subscription is made last produced element will be
    immediately replayed on the same thread on which the subscription was made.

    When using `drive*`, `subscribe*` and `bind*` family of methods, they should always be called from main thread.

    If `drive*`, `subscribe*` and `bind*` are called from background thread, it is possible that initial replay
    will happen on background thread, and subsequent events will arrive on main thread.

    To find out more about units and how to use them, please visit `Documentation/Units.md`.
*/
public struct Driver<Element> : DriverConvertibleType {
    public typealias E = Element

    let _source: Observable<E>

    init(_ source: Observable<E>) {
        self._source = source.shareReplayLatestWhileConnected()
    }

    init(raw: Observable<E>) {
        self._source = raw
    }

    #if EXPANDABLE_DRIVER
    public static func createUnsafe<O: ObservableType>(source: O) -> Driver<O.E> {
        return Driver<O.E>(raw: source.asObservable())
    }
    #endif

    /**
    - returns: Built observable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return _source
    }

    /**
    - returns: `self`
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asDriver() -> Driver<E> {
        return self
    }
}


extension Driver {

    /**
    Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

    - returns: An observable sequence with no elements.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func empty() -> Driver<E> {
        return Driver(raw: Observable.empty().subscribeOn(driverSubscribeOnScheduler))
    }

    /**
    Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

    - returns: An observable sequence whose observers will never get called.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func never() -> Driver<E> {
        return Driver(raw: Observable.never().subscribeOn(driverSubscribeOnScheduler))
    }

    /**
    Returns an observable sequence that contains a single element.

    - parameter element: Single element in the resulting observable sequence.
    - returns: An observable sequence containing the single specified element.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func just(element: E) -> Driver<E> {
        return Driver(raw: Observable.just(element).subscribeOn(driverSubscribeOnScheduler))
    }

    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func deferred(observableFactory: () -> Driver<E>)
        -> Driver<E> {
        return Driver(Observable.deferred { observableFactory().asObservable() })
    }

    /**
    This method creates a new Observable instance with a variable number of elements.

    - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

    - parameter elements: Elements to generate.
    - returns: The observable sequence whose elements are pulled from the given arguments.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func of(elements: E ...) -> Driver<E> {
        let source = elements.toObservable(driverSubscribeOnScheduler)
        return Driver(raw: source)
    }
}

extension Driver where Element : SignedIntegerType {
    /**
     Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.

     - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)

     - parameter period: Period for producing the values in the resulting sequence.
     - returns: An observable sequence that produces a value after each period.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func interval(period: RxTimeInterval)
        -> Driver<E> {
        return Driver(Observable.interval(period, scheduler: driverObserveOnScheduler))
    }
}

// MARK: timer

extension Driver where Element: SignedIntegerType {
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: Relative time at which to produce the first value.
     - parameter period: Period to produce subsequent values.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func timer(dueTime: RxTimeInterval, period: RxTimeInterval)
        -> Driver<E> {
        return Driver(Observable.timer(dueTime, period: period, scheduler: driverObserveOnScheduler))
    }
}

/**
 This method can be used in unit tests to ensure that driver is using mock schedulers instead of
 main schedulers.

 **This shouldn't be used in normal release builds.**
*/
public func driveOnScheduler(scheduler: SchedulerType, action: () -> ()) {
    let originalObserveOnScheduler = driverObserveOnScheduler
    let originalSubscribeOnScheduler = driverSubscribeOnScheduler

    driverObserveOnScheduler = scheduler
    driverSubscribeOnScheduler = scheduler

    action()

    // If you remove this line , compiler buggy optimizations will change behavior of this code
    _forceCompilerToStopDoingInsaneOptimizationsThatBreakCode(driverObserveOnScheduler)
    _forceCompilerToStopDoingInsaneOptimizationsThatBreakCode(driverSubscribeOnScheduler)
    // Scary, I know

    driverObserveOnScheduler = originalObserveOnScheduler
    driverSubscribeOnScheduler = originalSubscribeOnScheduler
}

func _forceCompilerToStopDoingInsaneOptimizationsThatBreakCode(scheduler: SchedulerType) {
    let a: Int32 = 1
    let b = 314 + Int32(arc4random() & 1)
    if a == b {
        print(scheduler)
    }
}

var driverObserveOnScheduler: SchedulerType = MainScheduler.instance
var driverSubscribeOnScheduler: SchedulerType = ConcurrentMainScheduler.instance
