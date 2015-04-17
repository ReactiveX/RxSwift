//
//  DispatchQueueScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class DispatchQueueScheduler : Scheduler {
    public typealias Time = NSDate
    public typealias TimeInterval = NSTimeInterval
    
    private let queue : dispatch_queue_t
    
    public init(queue: dispatch_queue_t) {
        self.queue = queue
        
    }
    
    // DISPATCH_QUEUE_PRIORITY_DEFAULT
    // DISPATCH_QUEUE_PRIORITY_HIGH
    // DISPATCH_QUEUE_PRIORITY_LOW
    convenience public init(priority: Int) {
        self.init(queue: dispatch_get_global_queue(priority, UInt(0)))
    }
    
    public var now : NSDate {
        get {
            return NSDate()
        }
    }
    
    class func convertTimeIntervalToDispatchTime(timeInterval: NSTimeInterval) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC) / 1000))
    }
    
    public func schedule<StateType>(state: StateType, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        dispatch_async(self.queue, {
            ensureScheduledSuccessfully(action(state))
        })
        
        return success(DefaultDisposable())
    }
    
    public func scheduleRelative<StateType>(state: StateType, dueTime: NSTimeInterval, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue)
        
        let dispatchInterval = MainScheduler.convertTimeIntervalToDispatchTime(dueTime)
        
        dispatch_source_set_timer(timer, dispatchInterval, DISPATCH_TIME_FOREVER, 0)
        dispatch_source_set_event_handler(timer, {
            ensureScheduledSuccessfully(action(state))
        })
        dispatch_resume(timer)
        
        return success(AnonymousDisposable {
            dispatch_source_cancel(timer)
        })
    }
}