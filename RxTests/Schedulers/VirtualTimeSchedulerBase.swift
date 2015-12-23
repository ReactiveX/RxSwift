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
public class VirtualTimeSchedulerBase<C: VirtualTimeConverterType>
    : SchedulerType
    , CustomDebugStringConvertible {

    public typealias Time = C.VirtualTimeUnit
    public typealias TimeInterval = C.VirtualTimeIntervalUnit

    private var enabled : Bool

    public private(set) var clock: Time

    private var _schedulerQueue : [ScheduledItem<Time>] = []
    private var _converter: C

    public var now: RxTime {
        return _converter.convertFromVirtualTime(clock)
    }

    /**
     Creates a new virtual time scheduler.
     
     - parameter initialClock: Initial value for the clock.
    */
    public init(initialClock: Time, converter: C) {
        self.clock = initialClock
        self.enabled = false
        _converter = converter
    }

    /**
    Schedules an action to be executed immediatelly.

    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func schedule<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        return self.scheduleRelative(state, dueTime: 0.0) { a in
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
    public func scheduleRelative<StateType>(state: StateType, dueTime: RxTimeInterval, action: StateType -> Disposable) -> Disposable {
        let time = self.now.dateByAddingTimeInterval(dueTime)
        let absoluteTime = _converter.convertToVirtualTime(time)
        return scheduleAbsoluteVirtual(state, time: absoluteTime, action: action)
    }

    /**
     Schedules an action to be executed after relative time has passed.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action. If this is less or equal then `now`, `now + 1`  will be used.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    func scheduleRelativeVirtual<StateType>(state: StateType, dueTime: TimeInterval, action: StateType -> Disposable) -> Disposable {
        let time = _converter.addVirtualTimeAndTimeInterval(time: self.clock, timeInterval: dueTime)
        return scheduleAbsoluteVirtual(state, time: time, action: action)
    }

    /**
     Schedules an action to be executed at absolute virtual time.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action. If this is less or equal then `now`, `now + 1`  will be used.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    func scheduleAbsoluteVirtual<StateType>(state: StateType, time: Time, action: StateType -> Disposable) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        
        let scheduleTime: C.VirtualTimeUnit
        if time <= self.clock {
            scheduleTime = _converter.nearFuture(self.clock)
        }
        else {
            scheduleTime = time
        }
        
        let item = ScheduledItem(action: { action(state) }, time: scheduleTime)
        
        _schedulerQueue.append(item)
        
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
                    
                    if next.time > self.clock {
                        self.clock = next.time
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
    
    func getNext() -> ScheduledItem<Time>? {
        var minDate: C.VirtualTimeUnit? = nil
        var minElement : ScheduledItem<Time>? = nil
        var minIndex = -1
        var index = 0
        
        for item in self._schedulerQueue {
            if minDate == nil || item.time < minDate {
                minDate = item.time
                minElement = item
                minIndex = index
            }
            
            index++
        }
        
        if minElement != nil {
            self._schedulerQueue.removeAtIndex(minIndex)
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
            return self._schedulerQueue.description
        }
    }
}

class ScheduledItem<Time>
    : Disposable {
    typealias Action = () -> Disposable
    
    let action: Action
    let time: Time
    
    var disposed: Bool {
        get {
            return disposable.disposed
        }
    }
    
    var disposable = SingleAssignmentDisposable()
    
    init(action: Action, time: Time) {
        self.action = action
        self.time = time
    }
    
    func invoke() {
         self.disposable.disposable = action()
    }
    
    func dispose() {
        self.disposable.dispose()
    }
}
