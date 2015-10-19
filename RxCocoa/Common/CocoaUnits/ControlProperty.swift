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
        - it's stateful, upon subscription (calling subscribe) last element is immediatelly replayed if it was produced
    - it will `Complete` sequence on control being deallocated
    - it never errors out
    - it delivers events on `MainScheduler.sharedInstance`
*/
public struct ControlProperty<PropertyType> : ControlPropertyType {
    public typealias E = PropertyType
    
    let source: Observable<PropertyType>
    let observer: AnyObserver<PropertyType>
    
    init(source: Observable<PropertyType>, observer: AnyObserver<PropertyType>) {
        self.source = source.subscribeOn(ConcurrentMainScheduler.sharedInstance)
        self.observer = observer
    }
    
    /**
    Subscribes an observer to control property values.
    
    - parameter observer: Observer to subscribe to property values.
    - returns: Disposable object that can be used to unsubscribe the observer from receiving control property values.
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
    - returns: `ControlProperty` interface.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asControlProperty() -> ControlProperty<E> {
        return self
    }
 
    /**
    Binds event to user interface.
    
    - In case next element is received, it is being set to control value.
    - In case error is received, DEBUG buids raise fatal error, RELEASE builds log event to standard output.
    - In case sequence completes, nothing happens.
    */
    public func on(event: Event<E>) {
        switch event {
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Next:
            self.observer.on(event)
        case .Completed:
            self.observer.on(event)
        }
    }
}