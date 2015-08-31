//
//  Timer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TimerSink<S: Scheduler, O: ObserverType where O.E == Int64> : Sink<O> {
    typealias Parent = Timer<S>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return self.parent.scheduler.schedulePeriodic(0 as Int64, startAfter: self.parent.dueTime, period: self.parent.period!) { state in
            self.observer?.on(.Next(state))
            return state &+ 1
        }
    }
}

class TimerOneOffSink<S: Scheduler, O: ObserverType where O.E == Int64> : Sink<O> {
    typealias Parent = Timer<S>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return self.parent.scheduler.scheduleRelative((), dueTime: self.parent.dueTime) { (_) -> Disposable in
            self.observer?.on(.Next(0))
            self.observer?.on(.Completed)
            
            return NopDisposable.instance
        }
    }
}

class Timer<S: Scheduler>: Producer<Int64> {
    typealias TimeInterval = S.TimeInterval
    
    let scheduler: S
    let dueTime: TimeInterval
    let period: TimeInterval?
    
    init(dueTime: TimeInterval, period: TimeInterval?, scheduler: S) {
        self.scheduler = scheduler
        self.dueTime = dueTime
        self.period = period
    }
    
    override func run<O : ObserverType where O.E == Int64>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let _ = period {
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