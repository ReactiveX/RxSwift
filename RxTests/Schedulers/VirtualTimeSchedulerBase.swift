//
//  VirtualTimeSchedulerBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
Base class for virtual time schedulers using a priority queue for scheduled items.
*/
public class VirtualTimeSchedulerBase
    : SchedulerType
    , CustomDebugStringConvertible {

    public typealias TimeInterval = Time
    public typealias Time = RxTests.Time
    
    private var enabled : Bool
    
    public private(set) var now: Time

    private var schedulerQueue : [ScheduledItemProtocol] = []

    /**
     Creates a new virtual time scheduler.
     
     - parameter initialClock: Initial value for the clock.
    */
    public init(initialClock: Time) {
        self.now = initialClock
        self.enabled = false
    }

    /**
    Schedules an action to be executed immediatelly.

    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func schedule<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        return self.scheduleRelative(state, dueTime: 0) { a in
            return action(a)
        }
    }

    /**
     Schedules an action to be executed.

     - parameter state: State passed to the action to be executed.
     - parameter dueTime: Relative time after which to execute the action.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func scheduleRelative<StateType>(state: StateType, dueTime: Time, action: StateType -> Disposable) -> Disposable {
        return schedule(state, time: now + dueTime, action: action)
    }

    /**
     Schedules an action to be executed at exact absolute time.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action. If this is less or equal then `now`, `now + 1`  will be used.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    func schedule<StateType>(state: StateType, time: Time, action: StateType -> Disposable) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        
        let scheduleTime: Time
        if time <= self.now {
            scheduleTime = self.now + 1
        }
        else {
            scheduleTime = time
        }
        
        let item = ScheduledItem(action: action, state: state, time: scheduleTime)
        
        schedulerQueue.append(item)
        
        compositeDisposable.addDisposable(item)
        
        return compositeDisposable
    }

    /**
    Starts the virtual time scheduler.
    */
    public func start() {
        if !enabled {
            enabled = true
            repeat {
                if let next = getNext() {
                    if next.disposed {
                        continue
                    }
                    
                    if next.time > self.now {
                        self.now = next.time
                    }

                    next.invoke()
                }
                else {
                    enabled = false;
                }
            
            } while enabled
        }
    }

    /**
    Stops the virtual time scheduler.
    */
    public func stop() {
        enabled = false
    }
    
    func getNext() -> ScheduledItemProtocol? {
        var minDate = Time.max
        var minElement : ScheduledItemProtocol? = nil
        var minIndex = -1
        var index = 0
        
        for item in self.schedulerQueue {
            if item.time < minDate {
                minDate = item.time
                minElement = item
                minIndex = index
            }
            
            index++
        }
        
        if minElement != nil {
            self.schedulerQueue.removeAtIndex(minIndex)
        }
        
        return minElement
    }
}

// MARK: description

extension VirtualTimeSchedulerBase {
    /**
    A textual representation of `self`, suitable for debugging.
    */
    public var debugDescription: String {
        get {
            return self.schedulerQueue.description
        }
    }
}

protocol ScheduledItemProtocol : Cancelable {
    var time: Time {
        get
    }
    
    func invoke()
}

class ScheduledItem<T> : ScheduledItemProtocol {
    typealias Action = T -> Disposable
    
    let action: Action
    let state: T
    let time: Time
    
    var disposed: Bool {
        get {
            return disposable.disposed
        }
    }
    
    var disposable = SingleAssignmentDisposable()
    
    init(action: Action, state: T, time: Time) {
        self.action = action
        self.state = state
        self.time = time
    }
    
    func invoke() {
         self.disposable.disposable = action(state)
    }
    
    func dispose() {
        self.disposable.dispose()
    }
}
