//
//  Lock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct Lock {
    private var _lock = OS_SPINLOCK_INIT
    
    public init() {
        
    }
    
    public mutating func performLocked(@noescape action: () -> Void) {
        OSSpinLockLock(&_lock)
        action()
        OSSpinLockUnlock(&_lock)
    }
    
    public mutating func calculateLocked<T>(@noescape action: () -> T) -> T {
        OSSpinLockLock(&_lock)
        let result = action()
        OSSpinLockUnlock(&_lock)
        return result
    }
}

extension NSRecursiveLock {
    func performLocked(@noescape action: () -> Void) {
        self.lock()
        action()
        self.unlock()
    }
    
    func calculateLocked<T>(@noescape action: () -> T) -> T {
        self.lock()
        let result = action()
        self.unlock()
        return result
    }
}