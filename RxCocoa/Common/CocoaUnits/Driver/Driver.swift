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

    @warn_unused_result(message="http://git.io/rxs.uo")
    public static func of(elements: E ...) -> Driver<E> {
        let source = elements.toObservable().subscribeOn(driverSubscribeOnScheduler)
        return Driver(raw: source)
    }

}

public struct Drive {

    @available(*, deprecated=2.0.0, message="Please use `Driver.empty` (`r` at the end).")
    public static func empty<E>() -> Driver<E> {
        return Driver(raw: Observable.empty().subscribeOn(driverSubscribeOnScheduler))
    }

    @available(*, deprecated=2.0.0, message="Please use `Driver.never` (`r` at the end).")
    public static func never<E>() -> Driver<E> {
        return Driver(raw: Observable.never().subscribeOn(driverSubscribeOnScheduler))
    }

    @available(*, deprecated=2.0.0, message="Please use `Driver.just` (`r` at the end).")
    public static func just<E>(element: E) -> Driver<E> {
        return Driver(raw: Observable.just(element).subscribeOn(driverSubscribeOnScheduler))
    }

    @available(*, deprecated=2.0.0, message="Please use `Driver.deferred` (`r` at the end).")
    public static func deferred<E>(observableFactory: () -> Driver<E>)
        -> Driver<E> {
        return Driver(Observable.deferred { observableFactory().asObservable() })
    }

    @available(*, deprecated=2.0.0, message="Please use `Driver.of` (`r` at the end).")
    public static func sequenceOf<E>(elements: E ...) -> Driver<E> {
        let source = elements.toObservable().subscribeOn(driverSubscribeOnScheduler)
        return Driver(raw: source)
    }

}

/**
 This method can be used in unit tests to ensure that driver is using mock schedulers instead of
 maind schedulers.

 **This shouldn't be used in normal release builds.**
*/
public func driveOnScheduler(scheduler: SchedulerType, action: () -> ()) {
    let originalObserveOnScheduler = driverObserveOnScheduler
    let originalSubscribeOnScheduler = driverSubscribeOnScheduler

    driverObserveOnScheduler = scheduler
    driverSubscribeOnScheduler = scheduler

    action()

    driverObserveOnScheduler = originalObserveOnScheduler
    driverSubscribeOnScheduler = originalSubscribeOnScheduler
}

var driverObserveOnScheduler: SchedulerType = MainScheduler.instance
var driverSubscribeOnScheduler: SchedulerType = ConcurrentMainScheduler.instance
