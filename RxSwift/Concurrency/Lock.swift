//
//  Lock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol Lock {
    func lock()
    func unlock()
}

/**
Simple wrapper for spin lock.
*/
struct SpinLock {
    private var _lock = OS_SPINLOCK_INIT
    
    init() {
        
    }

    mutating func lock() {
        OSSpinLockLock(&_lock)
    }

    mutating func unlock() {
        OSSpinLockUnlock(&_lock)
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

extension NSRecursiveLock : Lock {
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

/*
let RECURSIVE_MUTEX = _initializeRecursiveMutex()

func _initializeRecursiveMutex() -> pthread_mutex_t {
    var mutex: pthread_mutex_t = pthread_mutex_t()
    var mta: pthread_mutexattr_t = pthread_mutexattr_t()

    pthread_mutex_init(&mutex, nil)
    pthread_mutexattr_init(&mta)
    pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE)
    pthread_mutex_init(&mutex, &mta)

    return mutex
}

extension pthread_mutex_t {
    mutating func lock() {
        pthread_mutex_lock(&self)
    }

    mutating func unlock() {
        pthread_mutex_unlock(&self)
    }
}
*/