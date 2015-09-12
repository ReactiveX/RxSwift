//
//  Lock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension NSLocking {
    
    func performLocked(@noescape action: () throws -> Void) rethrows {
        try calculateLocked(action)
    }
    
    func calculateLocked<T>(@noescape action: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try action()
    }
}

/**
Simple wrapper for spin lock.
*/
class SpinLock: NSLocking {
    
    private var _lock = OS_SPINLOCK_INIT
    
    @objc func lock() {
        OSSpinLockLock(&_lock)
    }
    
    @objc func unlock() {
        OSSpinLockUnlock(&_lock)
    }
}