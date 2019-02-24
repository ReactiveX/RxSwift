//
//  Observable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public typealias Observable<Element> = ObservableSource<Element, (), Error>

/**
 Subscribes `observer` to receive events for this sequence.
 
 ### Grammar
 
 **Next\* (Error | Completed)?**
 
 * sequences can produce zero or more elements so zero or more `Next` events can be sent to `observer`
 * once an `Error` or `Completed` event is sent, the sequence terminates and can't produce any other elements
 
 It is possible that events are sent from different threads, but no two events can be sent concurrently to
 `observer`.
 
 ### Resource Management
 
 When sequence sends `Complete` or `Error` event all internal resources that compute sequence elements
 will be freed.
 
 To cancel production of sequence elements and free resources immediately, call `dispose` on returned
 subscription.
 
 - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
 */
public struct ObservableSource<ElementType, CompletedType, ErrorType>: ObservableType {
    public typealias Element = ElementType
    public typealias Completed = CompletedType
    public typealias Error = ErrorType
    
    /// Observer type.
    public typealias Observer = (Event<Element, Completed, Error>) -> Void
    
    internal let run: (@escaping Observer, Cancelable) -> (sink: DisposeSink, subscription: Disposable)
    
    public init(_ onSubscribe: @escaping (@escaping Observer) -> Disposable) {
        self.init(run: { observer, disposable in
            var _isStopped = AtomicInt(0)
 
            let subscription = onSubscribe { event in
                switch event {
                case .next:
                    if load(&_isStopped) == 0 {
                        observer(event)
                    }
                case .completed, .error:
                    if fetchOr(&_isStopped, 1) == 0 {
                        observer(event)
                    }
                }
            }
            return (sink: { fetchOr(&_isStopped, 1) }, subscription: subscription)
        })
    }
    
    internal init(run: @escaping (@escaping Observer, Cancelable) -> (sink: DisposeSink, subscription: Disposable)) {
        self.run = run
    }
    
    public func subscribe(_ observer: @escaping Observer) -> Disposable {
        let disposer = SinkDisposer()

        let stopOnCompletedOrDisposed: Observer = { event in
            switch event {
            case .next:
                if load(&disposer._state) != SinkDisposer.DisposeState.disposed.rawValue {
                    observer(event)
                }
            case .error, .completed:
                if fetchOr(&disposer._state, SinkDisposer.DisposeState.disposed.rawValue) != SinkDisposer.DisposeState.disposed.rawValue {
                    observer(event)
                }
            }
        }

        if !CurrentThreadScheduler.isScheduleRequired {
            // The returned disposable needs to release all references once it was disposed.
            let sinkAndSubscription = run(stopOnCompletedOrDisposed, disposer)
            disposer.setSinkAndSubscription(disposeSink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

            return disposer
        }
        else {
            return CurrentThreadScheduler.instance.schedule(()) { _ in
                let sinkAndSubscription = self.run(stopOnCompletedOrDisposed, disposer)
                disposer.setSinkAndSubscription(disposeSink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

                return disposer
            }
        }
    }
    
    public func asSource() -> ObservableSource<ElementType, CompletedType, ErrorType> {
        return self
    }
}

internal extension ObservableSource {
    typealias Observers = Bag<(Event<Element, Completed, Error >) -> Void>
}
    

internal typealias DisposeSink = () -> Void

fileprivate final class SinkDisposer: Cancelable {
    fileprivate enum DisposeState: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }
    
    fileprivate var _state = AtomicInt(0)
    private var _disposeSink: DisposeSink?
    private var _subscription: Disposable?
    
    var isDisposed: Bool {
        return isFlagSet(&self._state, DisposeState.disposed.rawValue)
    }
    
    func setSinkAndSubscription(disposeSink: @escaping DisposeSink, subscription: Disposable) {
        self._disposeSink = disposeSink
        self._subscription = subscription
        
        let previousState = fetchOr(&self._state, DisposeState.sinkAndSubscriptionSet.rawValue)
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            rxFatalError("Sink and subscription were already set")
        }
        
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            _disposeSink?()
            subscription.dispose()
            self._disposeSink = nil
            self._subscription = nil
        }
    }
    
    func dispose() {
        let previousState = fetchOr(&self._state, DisposeState.disposed.rawValue)
        
        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }
        
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            guard let sink = self._disposeSink else {
                rxFatalError("Sink not set")
            }
            guard let subscription = self._subscription else {
                rxFatalError("Subscription not set")
            }
            
            sink()
            subscription.dispose()
            
            self._disposeSink = nil
            self._subscription = nil
        }
    }
}

extension ObservableSource {
    /// Transforms observer of type R to type E using custom transform method.
    /// Each event sent to result observer is transformed and sent to `self`.
    ///
    /// - returns: observer that transforms events.
    public func mapObserver<Result>(observer: @escaping Observer, _ transform: @escaping (Result) -> Element) -> ObservableSource<Result, Completed, Error>.Observer {
        return { event in
            observer(event.map(transform))
        }
    }
}
