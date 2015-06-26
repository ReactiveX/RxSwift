//
//  Scheduler+Extensions.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// periodic scheduling

// Compiler will choose correct implementation depending on scheduler capabilities.
// 
// If scheduler has periodic scheduling capabilities, it will choose them.
// Fallback is periodic recursive scheduler SchedulePeriodicRecursive.

func abstractSchedulePeriodic<State, S: PeriodicScheduler>(
        scheduler: S
    )
    -> (
        state: State,
        startAfter: S.TimeInterval,
        period: S.TimeInterval,
        action: (state: State) -> State
    ) -> Disposable {
    return { state, startAfter, period, action in
        let result = scheduler.schedulePeriodic(state, startAfter: startAfter, period: period, action: action)
        ensureScheduledSuccessfully(result.map { _ in () })
        
        return result.get()
    }
}

func abstractSchedulePeriodic<State, S: Scheduler>(
        scheduler: S
    )
    -> (
        state: State,
        startAfter: S.TimeInterval,
        period: S.TimeInterval,
        action: (state: State) -> State
    ) -> Disposable {
    return { state, startAfter, period, action in
        let schedule = SchedulePeriodicRecursive(scheduler: scheduler, startAfter: startAfter, period: period, action: action, state: state)
            
        return schedule.start()
    }
}

// recursive scheduling

func scheduleRecursive<State, S: Scheduler>(scheduler: S, state: State, dueTime: S.TimeInterval,
    action: (state: State, scheduler: RecursiveSchedulerOf<State, S.TimeInterval>) -> Void) -> Disposable {
     
    let scheduler = RecursiveScheduler<State, S>(scheduler: scheduler, action: action)
     
    scheduler.schedule(state, dueTime: dueTime)
        
    return scheduler
}