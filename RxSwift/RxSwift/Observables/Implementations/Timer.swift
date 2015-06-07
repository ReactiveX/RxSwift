//
//  Timer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TimerSink<S: Scheduler, O: ObserverType where O.Element == Int64> : Sink<O> {
    typealias Parent = Timer<S>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let result = self.parent.schedulePeriodic(state: 0, startAfter: self.parent.dueTime, period: self.parent.period!) { state in
            trySendNext(self.observer, state)
            return state &+ 1
        }
        
        return result
    }
}

class TimerOneOffSink<S: Scheduler, O: ObserverType where O.Element == Int64> : Sink<O> {
    typealias Parent = Timer<S>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let result = self.parent.scheduler.scheduleRelative((), dueTime: self.parent.dueTime) { (_) -> RxResult<Disposable> in
            trySendNext(self.observer, 0)
            trySendCompleted(self.observer)
            
            return NopDisposableResult
        }
        
        ensureScheduledSuccessfully(result.map { _ in () })
        
        return result.get()
    }
}

class Timer<S: Scheduler>: Producer<Int64> {
    typealias TimeInterval = S.TimeInterval
    typealias SchedulePeriodic = (
        state: Int64,
        startAfter: S.TimeInterval,
        period: S.TimeInterval,
        action: (state: Int64) -> Int64
    ) -> Disposable
    
    let scheduler: S
    let dueTime: TimeInterval
    let period: TimeInterval?
    
    let schedulePeriodic: SchedulePeriodic
    
    init(dueTime: TimeInterval, period: TimeInterval?, scheduler: S, schedulePeriodic: SchedulePeriodic) {
        self.scheduler = scheduler
        self.dueTime = dueTime
        self.period = period
        self.schedulePeriodic = schedulePeriodic
    }
    
    override func run<O : ObserverType where O.Element == Int64>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let period = period {
            let sink = TimerSink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
        else {
            let sink = TimerOneOffSink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
    }
}