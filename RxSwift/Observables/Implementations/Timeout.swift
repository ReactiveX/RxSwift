//
//  Timeout.swift
//  Rx
//
//  Created by Tomi Koskinen on 13/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TimeoutSink<ElementType, Scheduler: SchedulerType, O: ObserverType where O.E == ElementType>
    : Sink<O>
    , LockOwnerType
    , ObserverType
    , SynchronizedOnType {
    typealias E = ElementType
    typealias Parent = Timeout<E, Scheduler>
    
    private let _parent: Parent
    let _lock = NSRecursiveLock()

    private let _timerD = SerialDisposable()
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        _createTimeoutTimer()
        return StableCompositeDisposable.create(_timerD, _parent._source.subscribe(self))
    }

    func on(event: Event<E>) {
        synchronizedOn(event)
    }
    
    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next:
            forwardOn(event)
            self._createTimeoutTimer()
        case .Error:
            forwardOn(event)
            dispose()
        case .Completed:
            forwardOn(event)
            dispose()
        }
    }
    
    private func _createTimeoutTimer() {
        if _timerD.disposed {
            return
        }
        
        let nextTimer = SingleAssignmentDisposable()
        
        _timerD.disposable = nextTimer
        
        nextTimer.disposable = _parent._scheduler.scheduleRelative((), dueTime: _parent._dueTime) {
            self.forwardOn(.Error(RxError.Timeout))
            self.dispose()
            
            return NopDisposable.instance
        }
    }
}


class Timeout<Element, Scheduler: SchedulerType> : Producer<Element> {
    
    private let _dueTime: Scheduler.TimeInterval
    private let _scheduler: Scheduler
    private let _source: Observable<Element>
    
    init(source: Observable<Element>, dueTime: Scheduler.TimeInterval, scheduler: Scheduler) {
        _source = source
        _dueTime = dueTime
        _scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = TimeoutSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}
