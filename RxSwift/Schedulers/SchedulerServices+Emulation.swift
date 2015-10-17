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
    
    let scheduler: S
    let startAfter: TimeInterval
    let period: TimeInterval
    let action: RecursiveAction
    
    var state: State
    var pendingTickCount: Int32 = 0
    
    init(scheduler: S, startAfter: TimeInterval, period: TimeInterval, action: RecursiveAction, state: State) {
        self.scheduler = scheduler
        self.startAfter = startAfter
        self.period = period
        self.action = action
        self.state = state
    }
    
    func start() -> Disposable {
        return scheduler.scheduleRecursive(SchedulePeriodicRecursiveCommand.Tick, dueTime: self.startAfter, action: self.tick)
    }
    
    func tick(command: SchedulePeriodicRecursiveCommand, scheduler: RecursiveScheduler) -> Void {
        // Tries to emulate periodic scheduling as best as possible.
        // The problem that could arise is if handling periodic ticks take too long, or
        // tick interval is short.
        switch command {
        case .Tick:
            scheduler.schedule(.Tick, dueTime: self.period)

            // The idea is that if on tick there wasn't any item enqueued, schedule to perform work immediatelly.
            // Else work will be scheduled after previous enqueued work completes.
            if OSAtomicIncrement32(&pendingTickCount) == 1 {
                self.tick(.DispatchStart, scheduler: scheduler)
            }

        case .DispatchStart:
            self.state = action(state)
            // Start work and schedule check is this last batch of work
            if OSAtomicDecrement32(&pendingTickCount) > 0 {
                // This gives priority to scheduler emulation, it's not perfect, but helps
                scheduler.schedule(SchedulePeriodicRecursiveCommand.DispatchStart)
            }
        }
    }
}