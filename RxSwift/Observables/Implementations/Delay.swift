//
//  Delay.swift
//  RxSwift
//
//  Created by tarunon on 2016/02/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DelaySink<ElementType, O: ObserverType>
    : Sink<O>
    , ObserverType where O.E == ElementType {
    typealias E = O.E
    typealias Source = Observable<E>
    typealias DisposeKey = Bag<Disposable>.KeyType
    
    private let _lock = NSRecursiveLock()

    private let _dueTime: RxTimeInterval
    private let _scheduler: SchedulerType
    
    private let _sourceSubscription = SingleAssignmentDisposable()
    private let _cancelable = SerialDisposable()

    // is scheduled some action
    private var _active = false
    // is "run loop" on different scheduler running
    private var _running = false
    private var _errorEvent: Event<E>? = nil

    // state
    private var _queue = Queue<(eventTime: RxTime, event: Event<E>)>(capacity: 0)
    private var _disposed = false
    
    init(observer: O, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        _dueTime = dueTime
        _scheduler = scheduler
        super.init(observer: observer)
    }

    // All of these complications in this method are caused by the fact that 
    // error should be propagated immediatelly. Error can bepotentially received on different
    // scheduler so this process needs to be synchronized somehow.
    //
    // Another complication is that scheduler is potentially concurrent so internal queue is used.
    func drainQueue(state: (), scheduler: AnyRecursiveScheduler<()>) {

        _lock.lock()    // {
            let hasFailed = _errorEvent != nil
            if !hasFailed {
                _running = true
            }
        _lock.unlock()  // }

        if hasFailed {
            return
        }

        var ranAtLeastOnce = false

        while true {
            _lock.lock() // {
                let errorEvent = _errorEvent

                let eventToForwardImmediatelly = ranAtLeastOnce ? nil : _queue.dequeue()?.event
                let nextEventToScheduleOriginalTime: Date? = ranAtLeastOnce && !_queue.isEmpty ? _queue.peek().eventTime : nil

                if let _ = errorEvent {
                }
                else  {
                    if let _ = eventToForwardImmediatelly {
                    }
                    else if let _ = nextEventToScheduleOriginalTime {
                        _running = false
                    }
                    else {
                        _running = false
                        _active = false
                    }
                }
            _lock.unlock() // {

            if let errorEvent = errorEvent {
                self.forwardOn(errorEvent)
                self.dispose()
                return
            }
            else {
                if let eventToForwardImmediatelly = eventToForwardImmediatelly {
                    ranAtLeastOnce = true
                    self.forwardOn(eventToForwardImmediatelly)
                    if case .completed = eventToForwardImmediatelly {
                        self.dispose()
                        return
                    }
                }
                else if let nextEventToScheduleOriginalTime = nextEventToScheduleOriginalTime {
                    let elapsedTime = _scheduler.now.timeIntervalSince(nextEventToScheduleOriginalTime)
                    let interval = _dueTime - elapsedTime
                    let normalizedInterval = interval < 0.0 ? 0.0 : interval
                    scheduler.schedule((), dueTime: normalizedInterval)
                    return
                }
                else {
                    return
                }
            }
        }
    }
    
    func on(_ event: Event<E>) {
        if event.isStopEvent {
            _sourceSubscription.dispose()
        }

        switch event {
        case .error(_):
            _lock.lock()    // {
                let shouldSendImmediatelly = !_running
                _queue = Queue(capacity: 0)
                _errorEvent = event
            _lock.unlock()  // }

            if shouldSendImmediatelly {
                forwardOn(event)
                dispose()
            }
        default:
            _lock.lock()    // {
                let shouldSchedule = !_active
                _active = true
                _queue.enqueue((_scheduler.now, event))
            _lock.unlock()  // }

            if shouldSchedule {
                _cancelable.disposable = _scheduler.scheduleRecursive((), dueTime: _dueTime, action: self.drainQueue)
            }
        }
    }
    
    func run(source: Source) -> Disposable {
        _sourceSubscription.disposable = source.subscribeSafe(self)
        return Disposables.create(_sourceSubscription, _cancelable)
    }
}

class Delay<Element>: Producer<Element> {
    private let _source: Observable<Element>
    private let _dueTime: RxTimeInterval
    private let _scheduler: SchedulerType
    
    init(source: Observable<Element>, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        _source = source
        _dueTime = dueTime
        _scheduler = scheduler
    }

    override func run<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        let sink = DelaySink(observer: observer, dueTime: _dueTime, scheduler: _scheduler)
        sink.disposable = sink.run(source: _source)
        return sink
    }
}
