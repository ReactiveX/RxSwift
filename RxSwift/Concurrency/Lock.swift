//
//  Lock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct SpinLock {
    private var _lock = OS_SPINLOCK_INIT
    
    init() {
        
    }
    
    mutating func performLocked(@noescape action: () -> Void) {
        OSSpinLockLock(&_lock)
        action()
        OSSpinLockUnlock(&_lock)
    }
    
    mutating func calculateLocked<T>(@noescape action: () -> T) -> T {
        OSSpinLockLock(&_lock)
        let result = action()
        OSSpinLockUnlock(&_lock)
        return result
    }

    mutating func calculateLockedOrFail<T>(@noescape action: () throws -> T) throws -> T {
        OSSpinLockLock(&_lock)
        defer {
            OSSpinLockUnlock(&_lock)
        }
        let result = try action()
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
    
    func calculateLockedOrFail<T>(@noescape action: () throws -> T) throws -> T {
        self.lock()
        defer {
            self.unlock()
        }
        let result = try action()
        return result
    }
}