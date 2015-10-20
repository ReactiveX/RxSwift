//
//  AsyncLock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
In case nobody holds this lock, the work will be queued and executed immediately
on thread that is requesting lock.

In case there is somebody currently holding that lock, action will be enqueued.
When owned of the lock finishes with it's processing, it will also execute
and pending work.

That means that enqueued work could possibly be executed later on a different thread.
*/
class AsyncLock : Disposable {
    typealias Action = () -> Void
    
    private let _lock = NSRecursiveLock()
    
    private var _queue: Queue<Action> = Queue(capacity: 2)

    private var _isAcquired: Bool = false
    private var _hasFaulted: Bool = false
    
    init() {
        
    }
    
    func wait(action: Action) {
        let isOwner = _lock.calculateLocked { () -> Bool in
            if _hasFaulted {
                return false
            }
            
            _queue.enqueue(action)
            let isOwner = !_isAcquired
            _isAcquired = true
            
            return isOwner
        }
        
        if !isOwner {
            return
        }
        
        while true {
            let nextAction = _lock.calculateLocked { () -> Action? in
                if _queue.count > 0 {
                    return _queue.dequeue()
                }
                else {
                    _isAcquired = false
                    return nil
                }
            }
            
            if let nextAction = nextAction {
                nextAction()
            }
            else {
                return
            }
        }
    }
    
    func dispose() {
        _lock.performLocked { oldState in
            _queue = Queue(capacity: 0)
            _hasFaulted = true
        }
    }
}
