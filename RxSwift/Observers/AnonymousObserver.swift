//
//  AnonymousObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AnonymousObserver<ElementType> : ObserverBase<ElementType> {
    typealias Element = ElementType
    
    typealias EventHandler = Event<Element> -> Void
    
    private let eventHandler : EventHandler
    
    init(_ eventHandler: EventHandler) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        self.eventHandler = eventHandler
    }

    override func onCore(event: Event<Element>) {
        return self.eventHandler(event)
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
#endif
}
