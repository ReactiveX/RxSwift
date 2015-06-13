//
//  AsyncLock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// In case nobody holds this lock, the work will be queued and executed immediately
// on thread that is requesting lock.
//
// In case there is somebody currently holding that lock, action will be enqueued.
// When owned of the lock finishes with it's processing, it will also execute
// and pending work.
//
// That means that enqueued work could possibly be executed later on a different thread.
class AsyncLock : Disposable {
    typealias Action = () -> Void
    
    private var lock = NSRecursiveLock()
    
    private var queue: Queue<Action> = Queue(capacity: 2)
    private var isAcquired: Bool = false
    private var hasFaulted: Bool = false
    
    init() {
        
    }
    
    func wait(action: Action) {
        let isOwner = lock.calculateLocked { () -> Bool in
            if self.hasFaulted {
                return false
            }
            
            self.queue.enqueue(action)
            let isOwner = !self.isAcquired
            self.isAcquired = true
            
            return isOwner
        }
        
        if !isOwner {
            return
        }
        
        while true {
            let nextAction = lock.calculateLocked { () -> Action? in
                if self.queue.count > 0 {
                    return self.queue.dequeue()
                }
                else {
                    self.isAcquired = false
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
        lock.performLocked { oldState in
            self.queue = Queue(capacity: 0)
            self.hasFaulted = true
        }
    }
}