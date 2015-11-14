//
//  CurrentThreadScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let CurrentThreadSchedulerKeyInstance = CurrentThreadSchedulerKey()
let CurrentThreadSchedulerQueueKeyInstance = CurrentThreadSchedulerQueueKey()

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

class CurrentThreadSchedulerQueueKey : NSObject, NSCopying {
    override func isEqual(object: AnyObject?) -> Bool {
        return object === CurrentThreadSchedulerQueueKeyInstance
    }
    
    override var hashValue: Int { return -904739207 }
    
    override func copy() -> AnyObject {
        return CurrentThreadSchedulerQueueKeyInstance
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return CurrentThreadSchedulerQueueKeyInstance
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
            return NSThread.currentThread().threadDictionary[CurrentThreadSchedulerQueueKeyInstance] as? ScheduleQueue
        }
        set {
            let threadDictionary = NSThread.currentThread().threadDictionary
            if let newValue = newValue {
                threadDictionary[CurrentThreadSchedulerQueueKeyInstance] = newValue
            }
            else {
                threadDictionary.removeObjectForKey(CurrentThreadSchedulerQueueKeyInstance)
            }
        }
    }
    
    /**
    Gets a value that indicates whether the caller must call a `schedule` method.
    */
    public static private(set) var isScheduleRequired: Bool {
        get {
            return NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] == nil
        }
        set(value) {
            if value {
                NSThread.currentThread().threadDictionary.removeObjectForKey(CurrentThreadSchedulerKeyInstance)
            }
            else {
                NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] = CurrentThreadSchedulerKeyInstance
            }
        }
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
        if CurrentThreadScheduler.isScheduleRequired {
            CurrentThreadScheduler.isScheduleRequired = false

            let disposable = action(state)

            defer {
                CurrentThreadScheduler.isScheduleRequired = true
                CurrentThreadScheduler.queue = nil
            }

            guard let queue = CurrentThreadScheduler.queue else {
                return disposable
            }

            while let latest = queue.value.tryDequeue() {
                if latest.disposed {
                    continue
                }
                latest.invoke()
            }

            return disposable
        }

        let existingQueue = CurrentThreadScheduler.queue

        let queue: RxMutableBox<Queue<ScheduledItemType>>
        if let existingQueue = existingQueue {
            queue = existingQueue
        }
        else {
            queue = RxMutableBox(Queue<ScheduledItemType>(capacity: 1))
            CurrentThreadScheduler.queue = queue
        }

        let scheduledItem = ScheduledItem(action: action, state: state)
        queue.value.enqueue(scheduledItem)
        return scheduledItem
    }
}