//
//  RecursiveLock.swift
//  Platform
//
//  Created by Krunoslav Zaher on 12/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

// https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSLock.swift
final class RecursiveLock {
    private var mutex = pthread_mutex_t()

    init() {
        var attrs = pthread_mutexattr_t()
        if pthread_mutexattr_init(&attrs) != 0 {
            fatalError("Failed to initialize mutext attr")
        }
        if pthread_mutexattr_settype(&attrs, Int32(PTHREAD_MUTEX_RECURSIVE)) != 0 {
            fatalError("Failed to set recursive mutex type")
        }
        let code = pthread_mutex_init(&mutex, &attrs)
        if code != 0 {
            fatalError("mutex initialization failed \(code)")
        }
        if pthread_mutexattr_destroy(&attrs) != 0 {
            fatalError("Failed to destory mutex attr")
        }

        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }

    deinit {
        if pthread_mutex_destroy(&mutex) != 0 {
            fatalError("mutex destroy failed")
        }
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
    }

    @inline(__always)
    final func lock() {
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
        if pthread_mutex_lock(&mutex) != 0 {
            fatalError("mutex lock failed")
        }
    }

    @inline(__always)
    final func unlock() {
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
        if pthread_mutex_unlock(&mutex) != 0 {
            fatalError("mutex unlock failed")
        }
    }
}


