//
//  AnyObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
A type-erased `ObserverType`.

Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying observer type.
*/
public struct AnyObserver<Element> : ObserverType {
    /**
    The type of elements in sequence that observer can observe.
    */
    public typealias E = Element
    
    /**
    Anonymous event handler type.
    */
    public typealias EventHandler = (Event<Element>) -> Void

    public let observer: EventHandler

    /**
    Construct an instance whose `on(event)` calls `eventHandler(event)`
    
    - parameter eventHandler: Event handler that observes sequences events.
    */
    public init(eventHandler: @escaping EventHandler) {
        self.observer = eventHandler
    }
    
    /**
    Construct an instance whose `on(event)` calls `observer.on(event)`
    
    - parameter observer: Observer that receives sequence events.
    */
    public init<O : ObserverType>(_ observer: O) where O.E == Element {
        self.observer = observer.on
    }
    
    /**
    Send `event` to this observer.
    
    - parameter event: Event instance.
    */
    public func on(_ event: Event<Element>) {
        return self.observer(event)
    }

    /**
     Erases type of observer and returns canonical observer.

     - returns: type erased observer.
     */
    public func asObserver() -> AnyObserver<E> {
        return self
    }
}

extension ObserverType {
    /**
    Erases type of observer and returns canonical observer.
    
    - returns: type erased observer.
    */
    public func asObserver() -> AnyObserver<E> {
        return AnyObserver(self)
    }
}
