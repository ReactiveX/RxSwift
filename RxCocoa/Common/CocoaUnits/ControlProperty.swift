//
//  ControlProperty.swift
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
Protocol that enables extension of `ControlProperty`.
*/
public protocol ControlPropertyType : ObservableType, ObserverType {

    /**
    - returns: `ControlProperty` interface
    */
    func asControlProperty() -> ControlProperty<E>
}

/**
    Unit for `Observable`/`ObservableType` that represents property of UI element.

    It's properties are:

    - it never fails
    - `shareReplay(1)` behavior
        - it's stateful, upon subscription (calling subscribe) last element is immediately replayed if it was produced
    - it will `Complete` sequence on control being deallocated
    - it never errors out
    - it delivers events on `MainScheduler.instance`

    **The implementation of `ControlProperty` will ensure that sequence of values is being subscribed on main scheduler
    (`subscribeOn(ConcurrentMainScheduler.instance)` behavior).**

    **It is implementor's responsibility to make sure that that all other properties enumerated above are satisfied.**

    **If they aren't, then using this unit communicates wrong properties and could potentially break someone's code.**

    **In case `values` observable sequence that is being passed into initializer doesn't satisfy all enumerated
    properties, please don't use this unit.**
*/
public struct ControlProperty<PropertyType> : ControlPropertyType {
    public typealias E = PropertyType

    let _values: Observable<PropertyType>
    let _valueSink: AnyObserver<PropertyType>

    /**
     Initializes control property with a observable sequence that represents property values and observer that enables
     binding values to property.

     - parameter values: Observable sequence that represents property values.
     - parameter valueSink: Observer that enables binding values to control property.
     - returns: Control property created with a observable sequence of values and an observer that enables binding values
     to property.
    */
    public init<V: ObservableType, S: ObserverType>(values: V, valueSink: S) where E == V.E, E == S.E {
        _values = values.subscribeOn(ConcurrentMainScheduler.instance)
        _valueSink = valueSink.asObserver()
    }

    /**
    Subscribes an observer to control property values.

    - parameter observer: Observer to subscribe to property values.
    - returns: Disposable object that can be used to unsubscribe the observer from receiving control property values.
    */
    public func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return _values.subscribe(observer)
    }

    /**
    - returns: `Observable` interface.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return _values
    }

    /**
    - returns: `ControlProperty` interface.
    */
    // @warn_unused_result(message:"http://git.io/rxs.uo")
    public func asControlProperty() -> ControlProperty<E> {
        return self
    }

    /**
    Binds event to user interface.

    - In case next element is received, it is being set to control value.
    - In case error is received, DEBUG buids raise fatal error, RELEASE builds log event to standard output.
    - In case sequence completes, nothing happens.
    */
    public func on(_ event: Event<E>) {
        switch event {
        case .error(let error):
            bindingErrorToInterface(error)
        case .next:
            _valueSink.on(event)
        case .completed:
            _valueSink.on(event)
        }
    }
}
