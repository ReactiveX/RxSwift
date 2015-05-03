//
//  AsyncLock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

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
            self.queue = Queue(capacity: 2)
            self.hasFaulted = true
        }
    }
}