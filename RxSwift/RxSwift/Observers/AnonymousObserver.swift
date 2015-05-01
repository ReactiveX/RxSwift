//
//  AnonymousObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class AnonymousObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    
    typealias EventHandler = Event<Element> -> Void
    
    private let eventHandler : EventHandler
    
    public init(_ eventHandler: EventHandler) {
        self.eventHandler = eventHandler
    }
    
    public func on(event: Event<Element>) {
        return self.eventHandler(event)
    }
}