//
//  VirtualTimeSchedulerBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

protocol ScheduledItemProtocol : Cancelable {
    var time: Int {
        get
    }
    
    func invoke()
}

class ScheduledItem<T> : ScheduledItemProtocol {
    typealias Action = T -> Disposable
    
    let action: Action
    let state: T
    let time: Int
    
    var disposed: Bool {
        get {
            return disposable.disposed
        }
    }
    
    var disposable = SingleAssignmentDisposable()
    
    init(action: Action, state: T, time: Int) {
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


class VirtualTimeSchedulerBase
    : SchedulerType
    , CustomDebugStringConvertible {

    typealias TimeInterval = Int
    typealias Time = Int
    
    var clock : Time
    var enabled : Bool
    
    var now: Time {
        get {
            return self.clock
        }
    }
    
    private var schedulerQueue : [ScheduledItemProtocol] = []
    
    init(initialClock: Time) {
        self.clock = initialClock
        self.enabled = false
    }
    
    func schedule<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        return self.scheduleRelative(state, dueTime: 0) { a in
            return action(a)
        }
    }
    
    func scheduleRelative<StateType>(state: StateType, dueTime: Int, action: StateType -> Disposable) -> Disposable {
        return schedule(state, time: now + dueTime, action: action)
    }
    
    func schedule<StateType>(state: StateType, time: Int, action: StateType -> Disposable) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        
        let scheduleTime: Int
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
    
    func start() {
        if !enabled {
            enabled = true
            repeat {
                if let next = getNext() {
                    if next.disposed {
                        continue
                    }
                    
                    if next.time > self.now {
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

extension VirtualTimeSchedulerBase {
    var debugDescription: String {
        get {
            return self.schedulerQueue.description
        }
    }
}