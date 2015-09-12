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

public class CurrentThreadScheduler : ImmediateSchedulerType {
    typealias ScheduleQueue = RxMutableBox<Queue<ScheduledItemType>>
    
    public static let instance = CurrentThreadScheduler()
    
    static var queue : ScheduleQueue? {
        get {
            return NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] as? ScheduleQueue
        }
        set {
            NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] = newValue
        }
    }
    
    static var isScheduleRequired: Bool {
        return NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] == nil
    }
    
    public func schedule<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable {
        let queue = CurrentThreadScheduler.queue
        
        if let queue = queue {
            let scheduledItem = ScheduledItem(action: action, state: state, time: 0)
            queue.value.enqueue(scheduledItem)
            return scheduledItem
        }
        
        let newQueue = RxMutableBox(Queue<ScheduledItemType>(capacity: 10))
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