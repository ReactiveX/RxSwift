//
//  Sink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Sink<O : ObserverType> :  Disposable {
    private typealias Element = O.Element
    
    typealias State = (
        observer: O?,
        cancel: Disposable,
        disposed: Bool
    )
    
    private var lock = SpinLock()
    private var _state: State
    
    var observer: O? {
        get {
            return lock.calculateLocked { _state.observer }
        }
    }
    
    var cancel: Disposable {
        get {
            return lock.calculateLocked { _state.cancel }
        }
    }
    
    var state: State {
        get {
            return lock.calculateLocked { _state }
        }
    }
    
    init(observer: O, cancel: Disposable) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        _state = (
            observer: observer,
            cancel: cancel,
            disposed: false
        )
    }
    
    func dispose() {
        var cancel: Disposable? = lock.calculateLocked {
            if _state.disposed {
                return nil
            }
            
            var cancel = _state.cancel
            
            _state.disposed = true
            _state.observer = nil
            _state.cancel = NopDisposable.instance
            
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