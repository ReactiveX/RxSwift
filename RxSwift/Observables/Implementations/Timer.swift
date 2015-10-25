//
//  Timer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TimerSink<S: SchedulerType, O: ObserverType where O.E == Int64> : Sink<O> {
    typealias Parent = Timer<S>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return _parent._scheduler.schedulePeriodic(0 as Int64, startAfter: _parent._dueTime, period: _parent._period!) { state in
            self.observer?.on(.Next(state))
            return state &+ 1
        }
    }
}

class TimerOneOffSink<S: SchedulerType, O: ObserverType where O.E == Int64> : Sink<O> {
    typealias Parent = Timer<S>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return _parent._scheduler.scheduleRelative((), dueTime: _parent._dueTime) { (_) -> Disposable in
            self.observer?.on(.Next(0))
            self.observer?.on(.Completed)
            
            return NopDisposable.instance
        }
    }
}

class Timer<S: SchedulerType>: Producer<Int64> {
    typealias TimeInterval = S.TimeInterval
    
    private let _scheduler: S
    private let _dueTime: TimeInterval
    private let _period: TimeInterval?
    
    init(dueTime: TimeInterval, period: TimeInterval?, scheduler: S) {
        _scheduler = scheduler
        _dueTime = dueTime
        _period = period
    }
    
    override func run<O : ObserverType where O.E == Int64>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let _ = _period {
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