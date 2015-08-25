//
//  ObserverOf.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct ObserverOf<Element> : ObserverType {
    public typealias E = Element
    
    public typealias SinkType = (Event<Element>) -> Void

    public let sink: SinkType

    /// Construct an instance whose `on(event)` calls `sink(event)`
    public init(sink: SinkType) {
        self.sink = sink
    }
    
    /// Construct an instance whose `on(event)` calls `observer.on(event)`
    public init<O : ObserverType where O.E == Element>(_ observer: O) {
        self.sink = { e in
            return observer.on(e)
        }
    }
    
    /// Send `event` to this observer.
    public func on(event: Event<Element>) {
        return self.sink(event)
    }
}

extension ObserverType {
    func asObserver() -> ObserverOf<E> {
        return ObserverOf(self)
    }
}