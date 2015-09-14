//
//  MainScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Abstracts work that needs to be performed on `MainThread`. In case `schedule` methods are called from main thread, it will perform action immediately without scheduling.

This scheduler is usually used to perform UI work.

Main scheduler is a specialization of `SerialDispatchQueueScheduler`.
*/
public final class MainScheduler : SerialDispatchQueueScheduler {
    
    private init() {
        super.init(serialQueue: dispatch_get_main_queue())
    }

    /**
    Singleton instance of `MainScheduler`
    */
    public static let sharedInstance: MainScheduler = MainScheduler()

    /**
    In case this method is called on a background thread it will throw an exception.
    */
    public class func ensureExecutingOnScheduler() {
        if !NSThread.currentThread().isMainThread {
            rxFatalError("Executing on backgound thread. Please use `MainScheduler.sharedInstance.schedule` to schedule work on main thread.")
        }
    }
    
    override func scheduleInternal<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        if NSThread.currentThread().isMainThread {
            return action(state)
        }
        
        return super.scheduleInternal(state, action: action)
    }
}
