//
//  Sink.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class Sink<O : ObserverType> : Disposable {
    fileprivate let _observer: O
    fileprivate let _cancel: Cancelable
    fileprivate var _disposed = AtomicInt(0)

    #if DEBUG
        fileprivate let _synchronizationTracker = SynchronizationTracker()
    #endif

    init(observer: O, cancel: Cancelable) {
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
#endif
        _observer = observer
        _cancel = cancel
    }
    
    final func forwardOn(_ event: Event<O.E>) {
        #if DEBUG
            _synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { _synchronizationTracker.unregister() }
        #endif
        if isFlagSet(&_disposed, 1) {
            return
        }
        _observer.on(event)
    }
    
    final func forwarder() -> SinkForward<O> {
        return SinkForward(forward: self)
    }

    final var disposed: Bool {
        return isFlagSet(&_disposed, 1)
    }

    func dispose() {
        fetchOr(&_disposed, 1)
        _cancel.dispose()
    }

    deinit {
#if TRACE_RESOURCES
       let _ =  Resources.decrementTotal()
#endif
    }
}

final class SinkForward<O: ObserverType>: ObserverType {
    typealias E = O.E
    
    private let _forward: Sink<O>
    
    init(forward: Sink<O>) {
        _forward = forward
    }
    
    final func on(_ event: Event<E>) {
        switch event {
        case .next:
            _forward._observer.on(event)
        case .error, .completed:
            _forward._observer.on(event)
            _forward._cancel.dispose()
        }
    }
}
