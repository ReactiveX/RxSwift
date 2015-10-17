//
//  SchedulerServices+Emulation.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum SchedulePeriodicRecursiveCommand {
    case Tick
    case DispatchStart
    case DispatchEnd
}

class SchedulePeriodicRecursive<State, S: SchedulerType> {
    typealias RecursiveAction = State -> State
    typealias TimeInterval = S.TimeInterval
    typealias RecursiveScheduler = RecursiveSchedulerOf<SchedulePeriodicRecursiveCommand, S.TimeInterval>
    
    private let _scheduler: S
    private let _startAfter: TimeInterval
    private let _period: TimeInterval
    private let _action: RecursiveAction
    
    private var _state: State
    private var _pendingTickCount: Int32 = 0
    
    init(scheduler: S, startAfter: TimeInterval, period: TimeInterval, action: RecursiveAction, state: State) {
        _scheduler = scheduler
        _startAfter = startAfter
        _period = period
        _action = action
        _state = state
    }
    
    func start() -> Disposable {
        return _scheduler.scheduleRecursive(SchedulePeriodicRecursiveCommand.Tick, dueTime: _startAfter, action: tick)
    }
    
    func tick(command: SchedulePeriodicRecursiveCommand, scheduler: RecursiveScheduler) {
        switch command {
        case .Tick:
            scheduler.schedule(.Tick, dueTime: _period)
            
            if OSAtomicIncrement32(&_pendingTickCount) == 1 {
                tick(.DispatchStart, scheduler: scheduler)
            }
        case .DispatchStart:
            _state = _action(_state)
            scheduler.schedule(SchedulePeriodicRecursiveCommand.DispatchEnd)
        case .DispatchEnd:
            if OSAtomicDecrement32(&_pendingTickCount) > 0 {
                scheduler.schedule(SchedulePeriodicRecursiveCommand.DispatchStart)
            }
        }
    }
}