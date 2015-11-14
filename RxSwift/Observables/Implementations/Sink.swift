//
//  Sink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Sink<O : ObserverType> : SingleAssignmentDisposable {
    private let _observer: O

    final func forwardOn(event: Event<O.E>) {
        if disposed {
            return
        }
        _observer.on(event)
    }

    init(observer: O) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        _observer = observer
    }

    deinit {
#if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
#endif
    }
}