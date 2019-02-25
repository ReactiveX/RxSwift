//
//  ObserveOn.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

     - seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)

     - parameter scheduler: Scheduler to notify observers on.
     - returns: The source sequence whose observations happen on the specified scheduler.
     */
    public func observeOn(_ scheduler: ImmediateSchedulerType)
        -> ObservableSource<Element, Completed, Error> {
        if let scheduler = scheduler as? SerialDispatchQueueScheduler {
            return ObservableSource(run: .run { observer, cancel in
                let sink = ObservableSource.ObserveOnSerialDispatchQueueSink(scheduler: scheduler, observer: observer, cancel: cancel)
                let subscription = self.asSource().subscribe(sink.on)
                return Disposables.create {
                    sink.dispose()
                    subscription.dispose()
                }
            })
        }
        else {
            return ObservableSource(run: .run { observer, cancel in
                let sink = ObservableSource.ObserveOnSink(scheduler: scheduler, observer: observer, cancel: cancel)
                let subscription = self.asSource().subscribe(sink.on)
                return Disposables.create {
                    sink.dispose()
                    subscription.dispose()
                }
            })
        }
    }
}

enum ObserveOnState : Int32 {
    // pump is not running
    case stopped = 0
    // pump is running
    case running = 1
}

extension ObservableSource {
    final fileprivate class ObserveOnSink {
        let _scheduler: ImmediateSchedulerType

        var _lock = SpinLock()
        let _observer: Observer
        
        // state
        var _state = ObserveOnState.stopped
        var _queue = Queue<Event<Element, Completed, Error>>(capacity: 10)

        let _scheduleDisposable = SerialDisposable()
        let _cancel: Cancelable

        init(scheduler: ImmediateSchedulerType, observer: @escaping Observer, cancel: Cancelable) {
            self._scheduler = scheduler
            self._observer = observer
            self._cancel = cancel
        }

        func on(_ event: Event<Element, Completed, Error>) {
            let shouldStart = self._lock.calculateLocked { () -> Bool in
                self._queue.enqueue(event)

                switch self._state {
                case .stopped:
                    self._state = .running
                    return true
                case .running:
                    return false
                }
            }

            if shouldStart {
                self._scheduleDisposable.disposable = self._scheduler.scheduleRecursive((), action: self.run)
            }
        }

        func run(_ state: (), _ recurse: (()) -> Void) {
            let (nextEvent, observer) = self._lock.calculateLocked { () -> (Event<Element, Completed, Error>?, Observer) in
                if !self._queue.isEmpty {
                    return (self._queue.dequeue(), self._observer)
                }
                else {
                    self._state = .stopped
                    return (nil, self._observer)
                }
            }

            if let nextEvent = nextEvent, !self._cancel.isDisposed {
                observer(nextEvent)
                if nextEvent.isStopEvent {
                    self.dispose()
                }
            }
            else {
                return
            }

            let shouldContinue = self._shouldContinue_synchronized()

            if shouldContinue {
                recurse(())
            }
        }

        func _shouldContinue_synchronized() -> Bool {
            self._lock.lock(); defer { self._lock.unlock() } // {
                if !self._queue.isEmpty {
                    return true
                }
                else {
                    self._state = .stopped
                    return false
                }
            // }
        }

        func dispose() {
            self._cancel.dispose()
            self._scheduleDisposable.dispose()
        }
    }
}

#if TRACE_RESOURCES
    fileprivate var _numberOfSerialDispatchQueueObservables = AtomicInt(0)
    extension Resources {
        /**
         Counts number of `SerialDispatchQueueObservables`.

         Purposed for unit tests.
         */
        public static var numberOfSerialDispatchQueueObservables: Int32 {
            return load(&_numberOfSerialDispatchQueueObservables)
        }
    }
#endif

extension ObservableSource {
    final fileprivate class ObserveOnSerialDispatchQueueSink {
        let scheduler: SerialDispatchQueueScheduler
        let observer: Observer

        let cancel: Cancelable

        var cachedScheduleLambda: (((sink: ObserveOnSerialDispatchQueueSink, event: Event<Element, Completed, Error>)) -> Disposable)!

        init(scheduler: SerialDispatchQueueScheduler, observer: @escaping Observer, cancel: Cancelable) {
            self.scheduler = scheduler
            self.observer = observer
            self.cancel = cancel

            self.cachedScheduleLambda = { pair in
                guard !cancel.isDisposed else { return Disposables.create() }

                pair.sink.observer(pair.event)

                if pair.event.isStopEvent {
                    pair.sink.dispose()
                }

                return Disposables.create()
            }
        }

        func on(_ event: Event<Element, Completed, Error>) {
            _ = self.scheduler.schedule((self, event), action: self.cachedScheduleLambda!)
        }

        func dispose() {
            self.cancel.dispose()
        }
    }
}
