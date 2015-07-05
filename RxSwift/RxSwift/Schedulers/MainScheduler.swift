//
//  MainScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct MainSchedulerSingleton {
    static let sharedInstance = MainScheduler()
}

public final class MainScheduler : SerialDispatchQueueScheduler {
    
    private init() {
        super.init(serialQueue: dispatch_get_main_queue())
    }
    
    public class var sharedInstance: MainScheduler {
        get {
            return MainSchedulerSingleton.sharedInstance
        }
    }
    
    public class func ensureExecutingOnScheduler() {
        if !NSThread.currentThread().isMainThread {
            rxFatalError("Executing on wrong scheduler")
        }
    }
    
    override func scheduleInternal<StateType>(state: StateType, action: (/*ImmediateScheduler,*/ StateType) -> RxResult<Disposable>) -> RxResult<Disposable> {
        if NSThread.currentThread().isMainThread {
            return action(state)
        }
        
        return super.scheduleInternal(state, action: action)
    }
}
