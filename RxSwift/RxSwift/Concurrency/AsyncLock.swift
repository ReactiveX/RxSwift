//
//  AsyncLock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AsyncLock : Disposable {
    typealias Action = () -> Result<Void>
    
    private var lock: Lock = Lock()
    
    private var queue: Queue<Action> = Queue(capacity: 2)
    private var isAcquired: Bool = false
    private var hasFaulted: Bool = false
    
    init() {
        
    }
    
    func wait(action: Action) -> Result<Void> {
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
            return SuccessResult
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
                let executeResult = nextAction() >>! { e in
                    self.dispose()
                    return .Error(e)
                }
                
                if executeResult.error != nil {
                    return executeResult
                }
            }
            else {
                return SuccessResult
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