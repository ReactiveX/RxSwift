//
//  SchedulerType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents an object that schedules units of work.
*/
public protocol SchedulerType: ImmediateSchedulerType {
    /**
    Type that represents time interval in the context of this scheduler.
    */
    typealias TimeInterval
    
    /**
    Type that represents absolute time in the context of this scheduler.
    */
    typealias Time
    
    /**
    - returns: Current time.
    */
    var now : Time {
        get
    }

    /**
    Schedules an action to be executed.
    
    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the action.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func scheduleRelative<StateType>(state: StateType, dueTime: TimeInterval, action: (StateType) -> Disposable) -> Disposable
 
    /**
    Schedules a periodic piece of work.
    
    - parameter state: State passed to the action to be executed.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func schedulePeriodic<StateType>(state: StateType, startAfter: TimeInterval, period: TimeInterval, action: (StateType) -> StateType) -> Disposable
}

extension SchedulerType {
    public func schedulePeriodic<StateType>(state: StateType, startAfter: TimeInterval, period: TimeInterval, action: (StateType) -> StateType) -> Disposable {
        let schedule = SchedulePeriodicRecursive(scheduler: self, startAfter: startAfter, period: period, action: action, state: state)
            
        return schedule.start()
    }

    func scheduleRecursive<State>(state: State, dueTime: TimeInterval, action: (state: State, scheduler: RecursiveSchedulerOf<State, TimeInterval>) -> Void) -> Disposable {
        let scheduler = RecursiveScheduler(scheduler: self, action: action)
         
        scheduler.schedule(state, dueTime: dueTime)
            
        return AnonymousDisposable {
            scheduler.dispose()
        }
    }
}