//
//  MainScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class MainScheduler : DispatchQueueScheduler {
    struct Singleton {
        static let sharedInstance = MainScheduler()
    }
    
    private init() {
        super.init(queue: dispatch_get_main_queue())
    }
    
    public class var sharedInstance: MainScheduler {
        get {
            return Singleton.sharedInstance
        }
    }
    
    public class func ensureExecutingOnScheduler() {
        if !NSThread.currentThread().isMainThread {
            rxFatalError("Executing on wrong scheduler")
        }
    }
    
    public override func schedule<StateType>(state: StateType, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        if NSThread.currentThread().isMainThread {
            ensureScheduledSuccessfully(action(state))
                
            return success(DefaultDisposable())
        }
        
        return super.schedule(state, action: action)
    }
}
