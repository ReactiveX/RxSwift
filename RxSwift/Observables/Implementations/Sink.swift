//
//  Sink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Sink<O : ObserverType> : SingleAssignmentDisposable {
    // state
    private var _observer: O

    var observer: O? {
        get {
            //_lock.lock(); defer { _lock.unlock() }
            return _observer
        }
    }

    func forward(event: Event<O.E>) {
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