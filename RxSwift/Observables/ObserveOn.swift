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
        -> Observable<E> {
            if let scheduler = scheduler as? SerialDispatchQueueScheduler {
                return ObserveOnSerialDispatchQueue(source: self.asObservable(), scheduler: scheduler)
            }
            else {
                return ObserveOn(source: self.asObservable(), scheduler: scheduler)
            }
    }
}

final fileprivate class ObserveOn<E> : Producer<E> {
    let scheduler: ImmediateSchedulerType
    let source: Observable<E>
    
    init(source: Observable<E>, scheduler: ImmediateSchedulerType) {
        self.scheduler = scheduler
        self.source = source
        
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
#endif
    }
    
    override func run(_ observer: @escaping (Event<E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let scheduler = self.scheduler

        var lock = SpinLock()

        // state
        var _state = ObserveOnState.stopped
        var queue = Queue<Event<E>>(capacity: 10)

        let scheduleDisposable = SerialDisposable()

        func _shouldContinue_synchronized() -> Bool {
            lock.lock(); defer { lock.unlock() } // {
                    if queue.count > 0 {
                        return true
                    }
                    else {
                        _state = .stopped
                        return false
                    }
            // }
        }
        let sink = Sink(observer: observer, cancel: cancel)
        let run:  ((), (()) -> ()) -> () = { state, recurse in
            let nextEvent = lock.calculateLocked { () -> Event<E>? in
                if queue.count > 0 {
                    return queue.dequeue()
                }
                else {
                    _state = .stopped
                    return nil
                }
            }

            if let nextEvent = nextEvent, !cancel.isDisposed {
                observer(nextEvent)
                if nextEvent.isStopEvent {
                    scheduleDisposable.dispose()
                    cancel.dispose()
                }
            }
            else {
                return
            }

            let shouldContinue = _shouldContinue_synchronized()

            if shouldContinue {
                recurse(())
            }
        }
        let subscription = source.subscribe { event in
            let shouldStart = lock.calculateLocked { () -> Bool in
                queue.enqueue(event)

                switch _state {
                case .stopped:
                    _state = .running
                    return true
                case .running:
                    return false
                }
            }

            if shouldStart {
                scheduleDisposable.disposable = scheduler.scheduleRecursive((), action: run)
            }
        }
        return (sink: sink, subscription: subscription)
    }
    
#if TRACE_RESOURCES
    deinit {
        let _ = Resources.decrementTotal()
    }
#endif
}

enum ObserveOnState : Int32 {
    // pump is not running
    case stopped = 0
    // pump is running
    case running = 1
}

//final fileprivate class ObserveOnSink<O: ObserverType> : ObserverBase<O.E> {
//    typealias E = O.E
//
//
//    init(scheduler: ImmediateSchedulerType, observer: O, cancel: Cancelable) {
//        _scheduler = scheduler
//        _observer = observer
//        _cancel = cancel
//    }
//
//    override func onCore(_ event: Event<E>) {
//        let shouldStart = _lock.calculateLocked { () -> Bool in
//            self._queue.enqueue(event)
//
//            switch self._state {
//            case .stopped:
//                self._state = .running
//                return true
//            case .running:
//                return false
//            }
//        }
//
//        if shouldStart {
//            _scheduleDisposable.disposable = self._scheduler.scheduleRecursive((), action: self.run)
//        }
//    }
//
//    func run(_ state: (), _ recurse: (()) -> ()) {
//        let (nextEvent, observer) = self._lock.calculateLocked { () -> (Event<E>?, O) in
//            if self._queue.count > 0 {
//                return (self._queue.dequeue(), self._observer)
//            }
//            else {
//                self._state = .stopped
//                return (nil, self._observer)
//            }
//        }
//
//        if let nextEvent = nextEvent, !_cancel.isDisposed {
//            observer.on(nextEvent)
//            if nextEvent.isStopEvent {
//                dispose()
//            }
//        }
//        else {
//            return
//        }
//
//        let shouldContinue = _shouldContinue_synchronized()
//
//        if shouldContinue {
//            recurse(())
//        }
//    }
//
//    func _shouldContinue_synchronized() -> Bool {
//        _lock.lock(); defer { _lock.unlock() } // {
//            if self._queue.count > 0 {
//                return true
//            }
//            else {
//                self._state = .stopped
//                return false
//            }
//        // }
//    }
//
//    override func dispose() {
//        super.dispose()
//
//        _cancel.dispose()
//        _scheduleDisposable.dispose()
//    }
//}

#if TRACE_RESOURCES
    fileprivate var _numberOfSerialDispatchQueueObservables: AtomicInt = 0
    extension Resources {
        /**
         Counts number of `SerialDispatchQueueObservables`.

         Purposed for unit tests.
         */
        public static var numberOfSerialDispatchQueueObservables: Int32 {
            return _numberOfSerialDispatchQueueObservables.valueSnapshot()
        }
    }
#endif

final fileprivate class ObserveOnSerialDispatchQueue<E> : Producer<E> {
    let scheduler: SerialDispatchQueueScheduler
    let source: Observable<E>

    init(source: Observable<E>, scheduler: SerialDispatchQueueScheduler) {
        self.scheduler = scheduler
        self.source = source

        #if TRACE_RESOURCES
            let _ = Resources.incrementTotal()
            let _ = AtomicIncrement(&_numberOfSerialDispatchQueueObservables)
        #endif
    }

    override func run(_ observer: @escaping (Event<E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)

        let cachedScheduleLambda: (Event<E>) -> Disposable = { event in
            sink.forwardOn(event)

            if event.isStopEvent {
                sink.dispose()
            }

            return Disposables.create()
        }

        let subscription = source.subscribe { event in
            _ = self.scheduler.schedule(event, action: cachedScheduleLambda)
        }

        return (sink: sink, subscription: subscription)
    }

    #if TRACE_RESOURCES
    deinit {
        let _ = Resources.decrementTotal()
        let _ = AtomicDecrement(&_numberOfSerialDispatchQueueObservables)
    }
    #endif
}
