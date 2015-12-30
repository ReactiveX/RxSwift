//
//  SchedulerServices+Emulation.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum SchedulePeriodicRecursiveCommand {
    case Tick
    case DispatchStart
}

class SchedulePeriodicRecursive<State> {
    typealias RecursiveAction = State -> State
    typealias RecursiveScheduler = AnyRecursiveScheduler<SchedulePeriodicRecursiveCommand>

    private let _scheduler: SchedulerType
    private let _startAfter: RxTimeInterval
    private let _period: RxTimeInterval
    private let _action: RecursiveAction

    private var _state: State
    private var _pendingTickCount: AtomicInt = 0

    init(scheduler: SchedulerType, startAfter: RxTimeInterval, period: RxTimeInterval, action: RecursiveAction, state: State) {
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
            if AtomicIncrement(&_pendingTickCount) == 1 {
                self.tick(.DispatchStart, scheduler: scheduler)
            }

        case .DispatchStart:
            _state = _action(_state)
            // Start work and schedule check is this last batch of work
            if AtomicDecrement(&_pendingTickCount) > 0 {
                // This gives priority to scheduler emulation, it's not perfect, but helps
                scheduler.schedule(SchedulePeriodicRecursiveCommand.DispatchStart)
            }
        }
    }
}
