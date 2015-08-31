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

// WIP
class CurrentThreadScheduler : ImmediateScheduler {
    
    static var isScheduleRequired: Bool {
        return NSThread.currentThread().threadDictionary[CurrentThreadSchedulerKeyInstance] == nil
    }
    
    func schedule<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable {
        return NopDisposable.instance
    }
}