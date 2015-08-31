//
//  Scheduler+Extensions.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Scheduler {
    public func schedulePeriodic<StateType>(state: StateType, startAfter: TimeInterval, period: TimeInterval, action: (StateType) -> StateType) -> Disposable {
        let schedule = SchedulePeriodicRecursive(scheduler: self, startAfter: startAfter, period: period, action: action, state: state)
            
        return schedule.start()
    }

    func scheduleRecursive<State>(state: State, dueTime: TimeInterval, action: (state: State, scheduler: RecursiveSchedulerOf<State, TimeInterval>) -> Void) -> Disposable {
         
        let scheduler = RecursiveScheduler(scheduler: self, action: action)
         
        scheduler.schedule(state, dueTime: dueTime)
            
        return scheduler
    }
}
