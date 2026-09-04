//
//  Sink.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class Sink<Observer: ObserverType>: Disposable {
    fileprivate let observer: Observer
    fileprivate let cancel: Cancelable
    private let disposed = AtomicInt(0)

    #if DEBUG
    private let synchronizationTracker = SynchronizationTracker()
    #endif

    init(observer: Observer, cancel: Cancelable) {
        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
        self.observer = observer
        self.cancel = cancel
    }

    final func forwardOn(_ event: Event<Observer.Element>) {
        #if DEBUG
        synchronizationTracker.register(synchronizationErrorMessage: .default)
        defer { self.synchronizationTracker.unregister() }
        #endif
        if isFlagSet(disposed, 1) {
            return
        }
        observer.on(event)
    }

    final func forwarder() -> SinkForward<Observer> {
        SinkForward(forward: self)
    }

    final var isDisposed: Bool {
        isFlagSet(disposed, 1)
    }

    /// Marks the sink as disposed without tearing anything down.
    ///
    /// `forwardOn` drops events once this flag is set, so an operator that must stop forwarding
    /// at an exact point can set it inside its own critical section and then run the actual
    /// teardown -- which calls out to user code -- after releasing its locks.
    final func markDisposed() {
        fetchOr(disposed, 1)
    }

    func dispose() {
        fetchOr(disposed, 1)
        cancel.dispose()
    }

    deinit {
        #if TRACE_RESOURCES
        _ = Resources.decrementTotal()
        #endif
    }
}

final class SinkForward<Observer: ObserverType>: ObserverType {
    typealias Element = Observer.Element

    private let forward: Sink<Observer>

    init(forward: Sink<Observer>) {
        self.forward = forward
    }

    final func on(_ event: Event<Element>) {
        switch event {
        case .next:
            forward.observer.on(event)
        case .error, .completed:
            forward.observer.on(event)
            forward.cancel.dispose()
        }
    }
}
