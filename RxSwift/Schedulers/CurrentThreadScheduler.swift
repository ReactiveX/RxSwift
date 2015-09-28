//
//  CurrentThreadScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let CurrentThreadSchedulerKeyInstance = CurrentThreadSchedulerKey()

class CurrentThreadSchedulerKey : NSObject, NSCopying {
    override func isEqual(object: AnyObject?) -> Bool {
        return object === CurrentThreadSchedulerKeyInstance
    }
    
    override var hashValue: Int { return -904739208 }
    
    override func copy() -> AnyObject {
        return CurrentThreadSchedulerKeyInstance
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return CurrentThreadSchedulerKeyInstance
    }
}

/**
Represents an object that schedules units of work on the current thread.

This is the default scheduler for operators that generate elements.

This scheduler is also sometimes called `trampoline scheduler`.
*/
public class CurrentThreadScheduler : ImmediateSchedulerType {
    typealias ScheduleQueue = RxMutableBox<Queue<ScheduledItemType>>
    
    /**
    The singleton instance of the current thread scheduler.
    */
    public static let instance = CurrentThreadScheduler()
    
    static var queue : ScheduleQueue? {
        get {
            return NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] as? ScheduleQueue
        }
        set {
            let threadDictionary = NSThread.currentThread().threadDictionary
            if let newValue = newValue {
                threadDictionary[CurrentThreadSchedulerKeyInstance] = newValue
            }
            else {
                threadDictionary.removeObjectForKey(CurrentThreadSchedulerKeyInstance)
            }
        }
    }
    
    /**
    Gets a value that indicates whether the caller must call a `schedule` method.
    */
    public static var isScheduleRequired: Bool {
        return NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] == nil
    }
    
    /**
    Schedules an action to be executed as soon as possible on current thread.
    
    If this method is called on some thread that doesn't have `CurrentThreadScheduler` installed, scheduler will be
    automatically installed and uninstalled after all work is performed.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func schedule<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable {
        let queue = CurrentThreadScheduler.queue
        
        if let queue = queue {
            let scheduledItem = ScheduledItem(action: action, state: state, time: 0)
            queue.value.enqueue(scheduledItem)
            return scheduledItem
        }
        
        let newQueue = RxMutableBox(Queue<ScheduledItemType>(capacity: 0))
        CurrentThreadScheduler.queue = newQueue
        
        action(state)
        
        while let latest = newQueue.value.tryDequeue() {
            if latest.disposed {
                continue
            }
            latest.invoke()
        }
        
        CurrentThreadScheduler.queue = nil
        
        return NopDisposable.instance
    }
}