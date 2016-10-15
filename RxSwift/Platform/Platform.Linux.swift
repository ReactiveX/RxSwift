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

    #if false
    public final class AtomicInt: ExpressibleByIntegerLiteral {
        public typealias IntegerLiteralType = Int
        fileprivate var value = 0
        fileprivate var _lock = NSRecursiveLock()
        public init(integerLiteral value: Int) {
            self.value = value
        }
        func lock() {
          _lock.lock()
        }
        func unlock() {
          _lock.unlock()
        }
    }
    public func >(lhs: AtomicInt, rhs: Int) -> Bool {
        return lhs.value > rhs
    }
    public func ==(lhs: AtomicInt, rhs: Int) -> Bool {
        return lhs.value == rhs
    }
    #else
    final class AtomicInt: ExpressibleByIntegerLiteral {
        typealias IntegerLiteralType = Int
        fileprivate var value = 0
        fileprivate var _lock = NSRecursiveLock()
        init(integerLiteral value: Int) {
            self.value = value
        }
        func lock() {
          _lock.lock()
        }
        func unlock() {
          _lock.unlock()
        }
    }
    func >(lhs: AtomicInt, rhs: Int) -> Bool {
        return lhs.value > rhs
    }
    func ==(lhs: AtomicInt, rhs: Int) -> Bool {
        return lhs.value == rhs
    }
    #endif

    func AtomicIncrement(_ increment: inout AtomicInt) -> Int {
        increment.lock(); defer { increment.unlock() } 
        increment.value += 1
        return increment.value
    }

    func AtomicDecrement(_ increment: inout AtomicInt) -> Int {
        increment.lock(); defer { increment.unlock() } 
        increment.value -= 1
        return increment.value
    }

    func AtomicCompareAndSwap(_ l: Int, _ r: Int, _ target: inout AtomicInt) -> Bool {
        target.lock(); defer { target.unlock() } 
        if target.value == l {
            target.value = r
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
