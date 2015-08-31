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

class SchedulePeriodicRecursive<State, S: Scheduler> {
    typealias RecursiveAction = State -> State
    typealias TimeInterval = S.TimeInterval
    typealias RecursiveScheduler = RecursiveSchedulerOf<SchedulePeriodicRecursiveCommand, S.TimeInterval>
    
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
        switch command {
        case .Tick:
            scheduler.schedule(.Tick, dueTime: self.period)
            
            if OSAtomicIncrement32(&pendingTickCount) == 1 {
                self.tick(.DispatchStart, scheduler: scheduler)
            }
            break
        case .DispatchStart:
            self.state = action(state)
            scheduler.schedule(SchedulePeriodicRecursiveCommand.DispatchEnd)
            break
        case .DispatchEnd:
            if OSAtomicDecrement32(&pendingTickCount) > 0 {
                scheduler.schedule(SchedulePeriodicRecursiveCommand.DispatchStart)
            }
            break
        }
    }
}