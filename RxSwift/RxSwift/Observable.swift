//
//  Observable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class Observable<Element> {
    public init() {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    /// Subscribes `observer` to receive events from this observable
    public func subscribe<O: ObserverType where O.Element == Element>(observer: O) -> Disposable {
        return abstractMethod()
    }
    
    deinit {
#if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
#endif
    }
}

