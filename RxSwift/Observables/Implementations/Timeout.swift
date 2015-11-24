//
//  Timeout.swift
//  Rx
//
//  Created by Tomi Koskinen on 13/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TimeoutSink<ElementType, Scheduler: SchedulerType, O: ObserverType where O.E == ElementType>: Sink<O>, LockOwnerType, ObserverType {
    typealias E = ElementType
    typealias Parent = Timeout<E, Scheduler>
    
    private let _parent: Parent
    
    let _lock = NSRecursiveLock()

    private let _timerD = SerialDisposable()
    private let _subscription = SerialDisposable()
    
    private var _id = 0
    private var _switched = false
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        let original = SingleAssignmentDisposable()
        _subscription.disposable = original
        
        _createTimeoutTimer()
        
        original.disposable = _parent._source.subscribeSafe(self)
        
        return StableCompositeDisposable.create(_subscription, _timerD)
    }

    func on(event: Event<E>) {
        switch event {
        case .Next:
            var onNextWins = false
            
            _lock.performLocked() {
                onNextWins = !self._switched
                if onNextWins {
                    self._id++
                }
            }
            
            if onNextWins {
                forwardOn(event)
                self._createTimeoutTimer()
            }
        case .Error, .Completed:
            var onEventWins = false
            
            _lock.performLocked() {
                onEventWins = !self._switched
                if onEventWins {
                    self._id++
                }
            }
            
            if onEventWins {
                forwardOn(event)
                self.dispose()
            }
        }
    }
    
    private func _createTimeoutTimer() {
        if _timerD.disposed {
            return
        }
        
        let nextTimer = SingleAssignmentDisposable()
        _timerD.disposable = nextTimer
        
        nextTimer.disposable = _parent._scheduler.scheduleRelative(_id, dueTime: _parent._dueTime) { state in
            
            var timerWins = false
            
            self._lock.performLocked() {
                self._switched = (state == self._id)
                timerWins = self._switched
            }
            
            if timerWins {
                if let other = self._parent._other {
                    self._subscription.disposable = other.subscribeSafe(self.forwarder())
                }
            }
            
            return NopDisposable.instance
        }
    }
}


class Timeout<Element, Scheduler: SchedulerType> : Producer<Element> {
    
    private let _source: Observable<Element>
    private let _dueTime: Scheduler.TimeInterval
    private let _other: Observable<Element>?
    private let _scheduler: Scheduler
    
    init(source: Observable<Element>, dueTime: Scheduler.TimeInterval, other: Observable<Element>?, scheduler: Scheduler) {
        _source = source
        _dueTime = dueTime
        _other = other
        _scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = TimeoutSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}
