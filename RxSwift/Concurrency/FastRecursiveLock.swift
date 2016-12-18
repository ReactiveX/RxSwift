//
//  FastRecursiveLock.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 12/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if EMBEDDED_RECURSIVELOCK
    import RxSwift
#endif

// https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSLock.swift
final class RecursiveLock {
    #if CYGWIN
    private var mutex = UnsafeMutablePointer<pthread_mutex_t?>.allocate(capacity: 1)
    #else
    private var mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    #endif

    init() {
        #if CYGWIN
            var attrib : pthread_mutexattr_t? = nil
        #else
            var attrib = pthread_mutexattr_t()
        #endif
        withUnsafeMutablePointer(to: &attrib) { attrs in
            pthread_mutexattr_settype(attrs, Int32(PTHREAD_MUTEX_RECURSIVE))
            pthread_mutex_init(mutex, attrs)
        }

        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }

    deinit {
        pthread_mutex_destroy(mutex)
        mutex.deinitialize()
        mutex.deallocate(capacity: 1)
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
    }

    @inline(__always)
    final func lock() {
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
        pthread_mutex_lock(mutex)
    }

    @inline(__always)
    final func unlock() {
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
        pthread_mutex_unlock(mutex)
    }

}
