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
            _lock.lock(); defer { _lock.unlock() }
            return _observer
        }
    }
    
    var cancel: Disposable {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _cancel
        }
    }
    
    init(observer: O, cancel: Disposable) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        _observer = observer
        _cancel = cancel
    }

    func _disposeInternal() -> Disposable? {
        _lock.lock(); defer { _lock.unlock() }

        if _disposed {
            return nil
        }
        
        let cancel = _cancel
        
        _disposed = true
        _observer = nil
        _cancel = NopDisposable.instance
        
        return cancel
    }
    
    func dispose() {
        _disposeInternal()?.dispose()
    }
    
    deinit {
#if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
#endif
    }
}