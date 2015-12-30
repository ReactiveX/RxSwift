//
//  ControlEvent.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

/**
Protocol that enables extension of `ControlEvent`.
*/
public protocol ControlEventType : ObservableType {

    /**
    - returns: `ControlEvent` interface
    */
    func asControlEvent() -> ControlEvent<E>
}

/**
    Unit for `Observable`/`ObservableType` that represents event on UI element.

    It's properties are:

    - it never fails
    - it won't send any initial value on subscription
    - it will `Complete` sequence on control being deallocated
    - it never errors out
    - it delivers events on `MainScheduler.instance`

    **The implementation of `ControlEvent` will ensure that sequence of events is being subscribed on main scheduler
     (`subscribeOn(ConcurrentMainScheduler.instance)` behavior).**

    **It is implementor's responsibility to make sure that that all other properties enumerated above are satisfied.**

    **If they aren't, then using this unit communicates wrong properties and could potentially break someone's code.**

    **In case `events` observable sequence that is being passed into initializer doesn't satisfy all enumerated
     properties, please don't use this unit.**
*/
public struct ControlEvent<PropertyType> : ControlEventType {
    public typealias E = PropertyType

    let _events: Observable<PropertyType>

    /**
     Initializes control event with a observable sequence that represents events.

     - parameter events: Observable sequence that represents events.
     - returns: Control event created with a observable sequence of events.
     */
    public init<Ev: ObservableType where Ev.E == E>(events: Ev) {
        _events = events.subscribeOn(ConcurrentMainScheduler.instance)
    }

    /**
    Subscribes an observer to control events.

    - parameter observer: Observer to subscribe to events.
    - returns: Disposable object that can be used to unsubscribe the observer from receiving control events.
    */
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        return _events.subscribe(observer)
    }

    /**
    - returns: `Observable` interface.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return _events
    }

    /**
    - returns: `ControlEvent` interface.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asControlEvent() -> ControlEvent<E> {
        return self
    }
}
