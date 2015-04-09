//
//  AnonymousObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class AnonymousObserver<ElementType> : ObserverClassType {
    typealias Element = ElementType
    
    typealias EventHandler = Event<Element> -> Result<Void>
    
    private let eventHandler : EventHandler
    
    public init(_ eventHandler: EventHandler) {
        self.eventHandler = eventHandler
    }
    
    public func on(event: Event<Element>) -> Result<Void> {
        return self.eventHandler(event)
    }
    
    func makeSafe(disposable: Disposable) -> AnonymousSafeObserver<Element> {
        return AnonymousSafeObserver(eventHandler: eventHandler, disposable: disposable)
    }
}