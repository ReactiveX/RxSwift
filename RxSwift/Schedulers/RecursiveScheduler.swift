//
//  RecursiveScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RecursiveScheduler<State, S: Scheduler>: RecursiveSchedulerOf<State, S.TimeInterval> {
    let scheduler: S
    
    init(scheduler: S, action: Action) {
        self.scheduler = scheduler
        super.init(action: action)
    }
    
    override func scheduleRelativeAdapter(state: State, dueTime: S.TimeInterval, action: State -> Disposable) -> Disposable {
        return scheduler.scheduleRelative(state, dueTime: dueTime, action: action)
    }
    
    override func scheduleAdapter(state: State, action: State -> Disposable) -> Disposable {
        return scheduler.schedule(state, action: action)
    }
}

public class RecursiveSchedulerOf<State, TimeInterval> : Disposable {
    public typealias ScheduleRelative = (State, TimeInterval) -> Void
    public typealias ScheduleImmediate = (State) -> Void
    
    typealias Action =  (state: State, scheduler: RecursiveSchedulerOf<State, TimeInterval>) -> Void

    let lock = NSRecursiveLock()
    let group = CompositeDisposable()
    
    var action: Action?
    
    init(action: Action) {
        self.action = action
    }

    // abstract methods

    func scheduleRelativeAdapter(state: State, dueTime: TimeInterval, action: State -> Disposable) -> Disposable {
        return abstractMethod()
    }
    
    func scheduleAdapter(state: State, action: State -> Disposable) -> Disposable {
        return abstractMethod()
    }
    
    // relative scheduling
    
    public func schedule(state: State, dueTime: TimeInterval) {

        var isAdded = false
        var isDone = false
        
        var removeKey: CompositeDisposable.DisposeKey? = nil
        let d = scheduleRelativeAdapter(state, dueTime: dueTime) { (state) -> Disposable in
            // best effort
            if self.group.disposed {
                return NopDisposable.instance
            }
            
            let action = self.lock.calculateLocked { () -> Action? in
                if isAdded {
                    self.group.removeDisposable(removeKey!)
                }
                else {
                    isDone = true
                }
                
                return self.action
            }
            
            if let action = action {
                action(state: state, scheduler: self)
            }
            
            return NopDisposable.instance
        }
            
        lock.performLocked {
            if !isDone {
                removeKey = group.addDisposable(d)
                isAdded = true
            }
        }
    }

    // immediate scheduling
    
    public func schedule(state: State) {
            
        var isAdded = false
        var isDone = false
        
        var removeKey: CompositeDisposable.DisposeKey? = nil
        let d = scheduleAdapter(state) { (state) -> Disposable in
            // best effort
            if self.group.disposed {
                return NopDisposable.instance
            }
            
            let action = self.lock.calculateLocked { () -> Action? in
                if isAdded {
                    self.group.removeDisposable(removeKey!)
                }
                else {
                    isDone = true
                }
                
                return self.action
            }
           
            if let action = action {
                action(state: state, scheduler: self)
            }
            
            return NopDisposable.instance
        }
        
        lock.performLocked {
            if !isDone {
                removeKey = group.addDisposable(d)
                isAdded = true
            }
        }
    }
    
    public func dispose() {
        self.lock.performLocked {
            self.action = nil
        }
        self.group.dispose()
    }
}

class RecursiveImmediateSchedulerOf<State> : Disposable {
    typealias Action =  (state: State, recurse: State -> Void) -> Void
    
    var lock = SpinLock()
    let group = CompositeDisposable()
    
    var action: Action?
    let scheduler: ImmediateScheduler
    
    init(action: Action, scheduler: ImmediateScheduler) {
        self.action = action
        self.scheduler = scheduler
    }
    
    // immediate scheduling
    
    func schedule(state: State) {
        
        var isAdded = false
        var isDone = false
        
        var removeKey: CompositeDisposable.DisposeKey? = nil
        let d = self.scheduler.schedule(state) { (state) -> Disposable in
            // best effort
            if self.group.disposed {
                return NopDisposable.instance
            }
            
            let action = self.lock.calculateLocked { () -> Action? in
                if isAdded {
                    self.group.removeDisposable(removeKey!)
                }
                else {
                    isDone = true
                }
                
                return self.action
            }
            
            if let action = action {
                action(state: state, recurse: self.schedule)
            }
            
            return NopDisposable.instance
        }
        
        lock.performLocked {
            if !isDone {
                removeKey = group.addDisposable(d)
                isAdded = true
            }
        }
    }
    
    func dispose() {
        self.lock.performLocked {
            self.action = nil
        }
        self.group.dispose()
    }
}