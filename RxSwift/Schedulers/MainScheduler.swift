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

This scheduler is optimized for `observeOn` operator. To ensure observable sequence is subscribed on main thread using `subscribeOn`
operator please use `ConcurrentMainScheduler` because it is more optimized for that purpose.
*/
public final class MainScheduler : SerialDispatchQueueScheduler {

    private let _mainQueue: dispatch_queue_t

    var numberEnqueued: Int32 = 0

    private init() {
        _mainQueue = dispatch_get_main_queue()
        super.init(serialQueue: _mainQueue)
    }

    /**
    Singleton instance of `MainScheduler`
    */
    public static let sharedInstance = MainScheduler()

    /**
    In case this method is called on a background thread it will throw an exception.
    */
    public class func ensureExecutingOnScheduler() {
        if !NSThread.currentThread().isMainThread {
            rxFatalError("Executing on backgound thread. Please use `MainScheduler.sharedInstance.schedule` to schedule work on main thread.")
        }
    }
    
    override func scheduleInternal<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        let currentNumberEnqueued = OSAtomicIncrement32(&numberEnqueued)

        if NSThread.currentThread().isMainThread && currentNumberEnqueued == 1 {
            let disposable = action(state)
            OSAtomicDecrement32(&numberEnqueued)
            return disposable
        }

        let cancel = SingleAssignmentDisposable()

        dispatch_async(_mainQueue) {
            if !cancel.disposed {
                action(state)
            }

            OSAtomicDecrement32(&self.numberEnqueued)
        }

        return cancel
    }
}

