//
//  Platform.Linux.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(Linux)
    ////////////////////////////////////////////////////////////////////////////////
    // This is not the greatest API in the world, this is just a tribute.
    // !!! Proof of concept until libdispatch becomes operational. !!!
    ////////////////////////////////////////////////////////////////////////////////

    import Foundation
    import XCTest
    import Glibc
    import SwiftShims

    // MARK: Atomic, just something that works for single thread case

    #if TRACE_RESOURCES
    public typealias AtomicInt = Int64
    #else
    typealias AtomicInt = Int64
    #endif

    func AtomicIncrement(_ increment: UnsafeMutablePointer<AtomicInt>) -> AtomicInt {
        increment.pointee = increment.pointee + 1
        return increment.pointee
    }

    func AtomicDecrement(_ increment: UnsafeMutablePointer<AtomicInt>) -> AtomicInt {
        increment.pointee = increment.pointee - 1
        return increment.pointee
    }

    func AtomicCompareAndSwap(_ l: AtomicInt, _ r: AtomicInt, _ target: UnsafeMutablePointer<AtomicInt>) -> Bool {
        //return __sync_val_compare_and_swap(target, l, r)
        if target.pointee == l {
            target.pointee = r
            return true
        }

        return false
    }

    extension Thread {

        // This is kind of dodgy, as it only works in cases where there is a run loop
        var isMainThread: Bool {
            return RunLoop.current == RunLoop.main
        }

        static func setThreadLocalStorageValue<T: AnyObject>(_ value: T?, forKey key: String) {
            let currentThread = Thread.current
            var threadDictionary = currentThread.threadDictionary

            if let newValue = value {
                threadDictionary[key] = newValue
            }
            else {
                threadDictionary[key] = nil
            }

            currentThread.threadDictionary = threadDictionary
        }

        static func getThreadLocalStorageValueForKey<T: AnyObject>(_ key: String) -> T? {
            let currentThread = Thread.current
            let threadDictionary = currentThread.threadDictionary

            return threadDictionary[key] as? T
        }
    }

#endif
