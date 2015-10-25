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
    - it delivers events on `MainScheduler.sharedInstance`
*/
public struct ControlEvent<PropertyType> : ControlEventType {
    public typealias E = PropertyType
    
    let source: Observable<PropertyType>
    
    init(source: Observable<PropertyType>) {
        self.source = source.subscribeOn(ConcurrentMainScheduler.sharedInstance)
    }
    
    /**
    Subscribes an observer to control events.
    
    - parameter observer: Observer to subscribe to events.
    - returns: Disposable object that can be used to unsubscribe the observer from receiving control events.
    */
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.source.subscribe(observer)
    }
    
    /**
    - returns: `Observable` interface.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asObservable() -> Observable<E> {
        return self.source
    }
    
    /**
    - returns: `ControlEvent` interface.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asControlEvent() -> ControlEvent<E> {
        return self
    }
}