//
//  Observer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// This is a base class for all of the internal observers/sinks
public class Observer<ElementType> : ObserverType {
    public typealias E = ElementType

    init() {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    public func on(event: Event<E>) {
        return abstractMethod()
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
#endif
}