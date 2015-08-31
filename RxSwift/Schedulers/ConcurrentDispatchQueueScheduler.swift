//
//  ConcurrentDispatchQueueScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ConcurrentDispatchQueueScheduler: Scheduler {
    public typealias TimeInterval = NSTimeInterval
    public typealias Time = NSDate
    
    private let queue : dispatch_queue_t
    
    public var now : NSDate {
        get {
            return NSDate()
        }
    }
    
    // leeway for scheduling timers
    var leeway: Int64 = 0
    
    public init(queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    // Convenience init for scheduler that wraps one of the global concurrent dispatch queues.
    //
    // DISPATCH_QUEUE_PRIORITY_DEFAULT
    // DISPATCH_QUEUE_PRIORITY_HIGH
    // DISPATCH_QUEUE_PRIORITY_LOW
    public convenience init(globalConcurrentQueuePriority: DispatchQueueSchedulerPriority) {
        var priority: Int = 0
        switch globalConcurrentQueuePriority {
        case .High:
            priority = DISPATCH_QUEUE_PRIORITY_HIGH
        case .Default:
            priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        case .Low:
            priority = DISPATCH_QUEUE_PRIORITY_LOW
        }
        self.init(queue: dispatch_get_global_queue(priority, UInt(0)))
    }
    
    class func convertTimeIntervalToDispatchInterval(timeInterval: NSTimeInterval) -> Int64 {
        return Int64(timeInterval * Double(NSEC_PER_SEC))
    }
    
    class func convertTimeIntervalToDispatchTime(timeInterval: NSTimeInterval) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, convertTimeIntervalToDispatchInterval(timeInterval))
    }
    
    public final func schedule<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        return self.scheduleInternal(state, action: action)
    }
    
    func scheduleInternal<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()
        
        dispatch_async(self.queue) {
            if cancel.disposed {
                return
            }
            
            cancel.disposable = action(state)
        }
        
        return cancel
    }
    
    public final func scheduleRelative<StateType>(state: StateType, dueTime: NSTimeInterval, action: (StateType) -> Disposable) -> Disposable {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue)
        
        let dispatchInterval = MainScheduler.convertTimeIntervalToDispatchTime(dueTime)
        
        let compositeDisposable = CompositeDisposable()
        
        dispatch_source_set_timer(timer, dispatchInterval, DISPATCH_TIME_FOREVER, 0)
        dispatch_source_set_event_handler(timer, {
            if compositeDisposable.disposed {
                return
            }
           compositeDisposable.addDisposable(action(state))
        })
        dispatch_resume(timer)
        
        compositeDisposable.addDisposable(AnonymousDisposable {
            dispatch_source_cancel(timer)
            })
        
        return compositeDisposable
    }
    
    public func schedulePeriodic<StateType>(state: StateType, startAfter: TimeInterval, period: TimeInterval, action: (StateType) -> StateType) -> RxResult<Disposable> {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue)
        
        let initial = MainScheduler.convertTimeIntervalToDispatchTime(startAfter)
        let dispatchInterval = MainScheduler.convertTimeIntervalToDispatchInterval(period)
        
        var timerState = state
        
        let validDispatchInterval = dispatchInterval < 0 ? 0 : UInt64(dispatchInterval)
        
        dispatch_source_set_timer(timer, initial, validDispatchInterval, 0)
        let cancel = AnonymousDisposable {
            dispatch_source_cancel(timer)
        }
        dispatch_source_set_event_handler(timer, {
            if cancel.disposed {
                return
            }
            timerState = action(timerState)
        })
        dispatch_resume(timer)
        
        return success(cancel)
    }
}