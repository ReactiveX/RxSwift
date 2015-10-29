//
//  RecursiveScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RecursiveScheduler<State, S: SchedulerType>: AnyRecursiveScheduler<State, S.TimeInterval> {
    private let _scheduler: S
    
    init(scheduler: S, action: Action) {
        _scheduler = scheduler
        super.init(action: action)
    }
    
    override func scheduleRelativeAdapter(state: State, dueTime: S.TimeInterval, action: State -> Disposable) -> Disposable {
        return _scheduler.scheduleRelative(state, dueTime: dueTime, action: action)
    }
    
    override func scheduleAdapter(state: State, action: State -> Disposable) -> Disposable {
        return _scheduler.schedule(state, action: action)
    }
}

/**
Type erased recursive scheduler.
*/
class AnyRecursiveScheduler<State, TimeInterval> {
    typealias Action =  (state: State, scheduler: AnyRecursiveScheduler<State, TimeInterval>) -> Void

    private let _lock = NSRecursiveLock()
    
    // state
    private let _group = CompositeDisposable()
    
    private var _action: Action?
    
    init(action: Action) {
        _action = action
    }

    // abstract methods

    func scheduleRelativeAdapter(state: State, dueTime: TimeInterval, action: State -> Disposable) -> Disposable {
        abstractMethod()
    }
    
    func scheduleAdapter(state: State, action: State -> Disposable) -> Disposable {
        abstractMethod()
    }
    
    /**
    Schedules an action to be executed recursively.
    
    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the recursive action.
    */
    func schedule(state: State, dueTime: TimeInterval) {

        var isAdded = false
        var isDone = false
        
        var removeKey: CompositeDisposable.DisposeKey? = nil
        let d = scheduleRelativeAdapter(state, dueTime: dueTime) { (state) -> Disposable in
            // best effort
            if self._group.disposed {
                return NopDisposable.instance
            }
            
            let action = self._lock.calculateLocked { () -> Action? in
                if isAdded {
                    self._group.removeDisposable(removeKey!)
                }
                else {
                    isDone = true
                }
                
                return self._action
            }
            
            if let action = action {
                action(state: state, scheduler: self)
            }
            
            return NopDisposable.instance
        }
            
        _lock.performLocked {
            if !isDone {
                removeKey = _group.addDisposable(d)
                isAdded = true
            }
        }
    }

    /**
    Schedules an action to be executed recursively.
    
    - parameter state: State passed to the action to be executed.
    */
    func schedule(state: State) {
            
        var isAdded = false
        var isDone = false
        
        var removeKey: CompositeDisposable.DisposeKey? = nil
        let d = scheduleAdapter(state) { (state) -> Disposable in
            // best effort
            if self._group.disposed {
                return NopDisposable.instance
            }
            
            let action = self._lock.calculateLocked { () -> Action? in
                if isAdded {
                    self._group.removeDisposable(removeKey!)
                }
                else {
                    isDone = true
                }
                
                return self._action
            }
           
            if let action = action {
                action(state: state, scheduler: self)
            }
            
            return NopDisposable.instance
        }
        
        _lock.performLocked {
            if !isDone {
                removeKey = _group.addDisposable(d)
                isAdded = true
            }
        }
    }
    
    func dispose() {
        _lock.performLocked {
            _action = nil
        }
        _group.dispose()
    }
}

/**
Type erased recursive scheduler.
*/
class RecursiveImmediateScheduler<State> {
    typealias Action =  (state: State, recurse: State -> Void) -> Void
    
    private var _lock = SpinLock()
    private let _group = CompositeDisposable()
    
    private var _action: Action?
    private let _scheduler: ImmediateSchedulerType
    
    init(action: Action, scheduler: ImmediateSchedulerType) {
        _action = action
        _scheduler = scheduler
    }
    
    // immediate scheduling
    
    /**
    Schedules an action to be executed recursively.
    
    - parameter state: State passed to the action to be executed.
    */
    func schedule(state: State) {
        
        var isAdded = false
        var isDone = false
        
        var removeKey: CompositeDisposable.DisposeKey? = nil
        let d = _scheduler.schedule(state) { (state) -> Disposable in
            // best effort
            if self._group.disposed {
                return NopDisposable.instance
            }
            
            let action = self._lock.calculateLocked { () -> Action? in
                if isAdded {
                    self._group.removeDisposable(removeKey!)
                }
                else {
                    isDone = true
                }
                
                return self._action
            }
            
            if let action = action {
                action(state: state, recurse: self.schedule)
            }
            
            return NopDisposable.instance
        }
        
        _lock.performLocked {
            if !isDone {
                removeKey = _group.addDisposable(d)
                isAdded = true
            }
        }
    }
    
    func dispose() {
        _lock.performLocked {
            _action = nil
        }
        _group.dispose()
    }
}