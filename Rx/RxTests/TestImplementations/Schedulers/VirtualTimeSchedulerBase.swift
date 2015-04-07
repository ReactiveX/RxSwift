//
//  VirtualTimeSchedulerBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Rx

protocol ScheduledItem {
    
}

class VirtualTimeSchedulerBase : Scheduler {
    typealias Time = Int
    typealias TimeInterval = Int
    
    typealias ScheduledItem = (() -> Result<Void>, AnyObject, Int, time: Int)
    
    var clock : Time
    var enabled : Bool
    
    var now : Time {
        get {
            return self.clock
        }
    }
    
    private var schedulerQueue : [ScheduledItem] = []
    private var ID : Int = 0
    
    init(initialClock: Time) {
        self.clock = initialClock
        self.enabled = false
    }
    
    func scheduleRelative<StateType>(state: StateType, after: Time, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        return self.schedule(state, date: Time(after + self.clock), action: action)
    }
    
    func schedule<StateType>(state: StateType, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        return self.scheduleRelative(state, after: 0, action: action)
    }
    
    func schedule<StateType>(state: StateType, dueTime: TimeInterval, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        return schedule(state, date: now + dueTime, action: action)
    }
    
    func schedule<StateType>(state: StateType, date: Time, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        let latestID = self.ID
        ID = ID + 1
        
        let timeInterval = self.clock
        
        let actionDescription : ScheduledItem = ({
            return action(state)
        }, Box(state), latestID, date)
        
        schedulerQueue.append(actionDescription)
        
        return success(AnonymousDisposable {
            var index : Int = 0
            
            for (_, _, id, _) in self.schedulerQueue {
                if id == latestID {
                    self.schedulerQueue.removeAtIndex(index)
                    return
                }
                
                index++
            }
        })
    }
    
    func start() {
        if !enabled {
            enabled = true
            do {
                if let next = getNext() {
                    if next.time > self.now {
                        self.clock = next.time
                    }

                    (next.0)()
                }
                else {
                    enabled = false;
                }
            
            } while enabled
        }
    }
    
    func getNext() -> ScheduledItem? {
        var minDate = Time.max
        var minElement : ScheduledItem? = nil
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