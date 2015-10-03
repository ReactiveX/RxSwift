//
//  Sink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Sink<O : ObserverType> : Disposable {
    private var _lock = SpinLock()
    
    // state
    private var _observer: O?
    private var _cancel: Disposable
    private var _disposed: Bool = false
    
    var observer: O? {
        get {
            return _lock.calculateLocked { _observer }
        }
    }
    
    var cancel: Disposable {
        get {
            return _lock.calculateLocked { _cancel }
        }
    }
    
    init(observer: O, cancel: Disposable) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        _observer = observer
        _cancel = cancel
    }
    
    func dispose() {
        let cancel: Disposable? = _lock.calculateLocked {
            if _disposed {
                return nil
            }
            
            let cancel = _cancel
            
            _disposed = true
            _observer = nil
            _cancel = NopDisposable.instance
            
            return cancel
        }
        
        if let cancel = cancel {
            cancel.dispose()
        }
    }
    
    deinit {
#if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
#endif
    }
}