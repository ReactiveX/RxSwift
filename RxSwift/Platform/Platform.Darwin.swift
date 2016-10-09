//
//  Platform.Darwin.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)

    import Darwin
    import Foundation

    #if TRACE_RESOURCES
    public typealias AtomicInt = Int32
    #else
    typealias AtomicInt = Int32
    #endif

    let AtomicCompareAndSwap = OSAtomicCompareAndSwap32Barrier
    let AtomicIncrement = OSAtomicIncrement32Barrier
    let AtomicDecrement = OSAtomicDecrement32Barrier

    public extension Thread {
        static func setThreadLocalStorageValue<T: AnyObject>(_ value: T?, forKey key: String
            ) {
            let currentThread = Thread.current
            let threadDictionary = currentThread.threadDictionary

            if let newValue = value {
                threadDictionary[key] = newValue
            }
            else {
                threadDictionary[key] = nil
            }

        }
        static func getThreadLocalStorageValueForKey<T>(_ key: String) -> T? {
            let currentThread = Thread.current
            let threadDictionary = currentThread.threadDictionary
            
            return threadDictionary[key] as? T
        }
    }
    
#endif
