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
}

class SchedulePeriodicRecursive<State, S: SchedulerType> {
    typealias RecursiveAction = State -> State
    typealias TimeInterval = S.TimeInterval
    typealias RecursiveScheduler = AnyRecursiveScheduler<SchedulePeriodicRecursiveCommand, S.TimeInterval>
    
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
        return _scheduler.scheduleRecursive(SchedulePeriodicRecursiveCommand.Tick, dueTime: _startAfter, action: self.tick)
    }
    
    func tick(command: SchedulePeriodicRecursiveCommand, scheduler: RecursiveScheduler) -> Void {
        // Tries to emulate periodic scheduling as best as possible.
        // The problem that could arise is if handling periodic ticks take too long, or
        // tick interval is short.
        switch command {
        case .Tick:
            scheduler.schedule(.Tick, dueTime: _period)
            
            // The idea is that if on tick there wasn't any item enqueued, schedule to perform work immediatelly.
            // Else work will be scheduled after previous enqueued work completes.
            if OSAtomicIncrement32(&_pendingTickCount) == 1 {
                self.tick(.DispatchStart, scheduler: scheduler)
            }
            
        case .DispatchStart:
            _state = _action(_state)
            // Start work and schedule check is this last batch of work
            if OSAtomicDecrement32(&_pendingTickCount) > 0 {
                // This gives priority to scheduler emulation, it's not perfect, but helps
                scheduler.schedule(SchedulePeriodicRecursiveCommand.DispatchStart)
            }
        }
    }
}
