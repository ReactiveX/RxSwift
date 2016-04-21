//
//  Timer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TimerSink<O: ObserverType where O.E : SignedInteger > : Sink<O> {
    typealias Parent = Timer<O.E>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        return _parent._scheduler.schedulePeriodic(state: 0 as O.E, startAfter: _parent._dueTime, period: _parent._period!) { state in
            self.forwardOn(event: .Next(state))
            return state &+ 1
        }
    }
}

class TimerOneOffSink<O: ObserverType where O.E : SignedInteger> : Sink<O> {
    typealias Parent = Timer<O.E>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        return _parent._scheduler.scheduleRelative(state: (), dueTime: _parent._dueTime) { (_) -> Disposable in
            self.forwardOn(event: .Next(0))
            self.forwardOn(event: .Completed)
            
            return NopDisposable.instance
        }
    }
}

class Timer<E: SignedInteger>: Producer<E> {
    private let _scheduler: SchedulerType
    private let _dueTime: RxTimeInterval
    private let _period: RxTimeInterval?
    
    init(dueTime: RxTimeInterval, period: RxTimeInterval?, scheduler: SchedulerType) {
        _scheduler = scheduler
        _dueTime = dueTime
        _period = period
    }
    
    override func run<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        if let _ = _period {
            let sink = TimerSink(parent: self, observer: observer)
            sink.disposable = sink.run()
            return sink
        }
        else {
            let sink = TimerOneOffSink(parent: self, observer: observer)
            sink.disposable = sink.run()
            return sink
        }
    }
}