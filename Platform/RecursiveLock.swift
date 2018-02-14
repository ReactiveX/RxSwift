//
//  RecursiveLock.swift
//  Platform
//
//  Created by Krunoslav Zaher on 12/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

final class RecursiveLock {
    
    private let mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    
    init() {
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
        
        mutex.initialize(to: pthread_mutex_t())
        
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        attr.initialize(to: pthread_mutexattr_t())
        pthread_mutexattr_init(attr)
        pthread_mutexattr_settype(attr, Int32(PTHREAD_MUTEX_RECURSIVE))
        
        pthread_mutex_init(mutex, attr)
        
        pthread_mutexattr_destroy(attr)
        attr.deinitialize()
        attr.deallocate(capacity: 1)
    }
    
    deinit {
        pthread_mutex_destroy(mutex)
        mutex.deinitialize(count: 1)
        mutex.deallocate(capacity: 1)
        
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
    }
    
    func lock() {
        pthread_mutex_lock(mutex)
        
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }
    
    func unlock() {
        pthread_mutex_unlock(mutex)
        
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
    }
    
}
