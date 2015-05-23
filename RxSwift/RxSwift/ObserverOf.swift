//
//  ObserverOf.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct ObserverOf<ElementType> {
    typealias Element = ElementType
    
    private typealias ObserverSinkType = (Event<Element>) -> Void

    private let observer: ObserverSinkType
    private let instance: AnyObject?

    /// Construct an instance whose `on(event)` calls `observer.on(event)`
    public init<O : ObserverType where O.Element == Element>(_ observer: O) {
        var observerReference = observer // this is because swift compiler crashing
        self.instance = observerReference
        self.observer = { e in
            return observerReference.on(e)
        }
    }
    
    /// Send `event` to this observer.
    public func on(event: Event<Element>) {
        return observer(event)
    }
}

public func dispatch<Element, S: SequenceType where S.Generator.Element == ObserverOf<Element>>(event: Event<Element>, observers: S?) {
    if let observers = observers {
        for o in observers {
            o.on(event)
        }
    }
}


public func dispatchNext<Element, S: SequenceType where S.Generator.Element == ObserverOf<Element>>(element: Element, observers: S?) {
    if let observers = observers {
        let event = Event.Next(RxBox(element))
        for o in observers {
            o.on(event)
        }
    }
}

public func dispatch<S: SequenceType, O: ObserverType where S.Generator.Element == O>(event: Event<O.Element>, observers: S?) {
    if let observers = observers {
        for o in observers {
            o.on(event)
        }
    }
}

public func dispatchNext<S: SequenceType, O: ObserverType where S.Generator.Element == O>(element: O.Element, observers: S?) {
    if let observers = observers {
        let event = Event.Next(RxBox(element))
        for o in observers {
            o.on(event)
        }
    }
}