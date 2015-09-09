//
//  ObserverOf.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
A type-erased `ObserverType`.

Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying observer type.
*/
public struct ObserverOf<Element> : ObserverType {
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
    public init(eventHandler: EventHandler) {
        self.observer = eventHandler
    }
    
    /**
    Construct an instance whose `on(event)` calls `observer.on(event)`
    
    - parameter observer: Observer that receives sequence events.
    */
    public init<O : ObserverType where O.E == Element>(_ observer: O) {
        self.observer = { e in
            return observer.on(e)
        }
    }
    
    /**
    Send `event` to this observer.
    
    - parameter event: Event instance.
    */
    public func on(event: Event<Element>) {
        return self.observer(event)
    }
}

extension ObserverType {
    /**
    Erases type of observer and returns canonical observer.
    
    - returns: type erased observer.
    */
    func asObserver() -> ObserverOf<E> {
        return ObserverOf(self)
    }
}