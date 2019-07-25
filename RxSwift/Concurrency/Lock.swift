//
//  Lock.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol Lock {
    func lock()
    func unlock()
}

// https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20151214/000321.html

@available(iOS 10.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *)
final class UnfairLock: Lock {
    private var unfairLock = os_unfair_lock_s()

    func lock() {
        os_unfair_lock_lock(&unfairLock)
    }

    func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}

final class Mutex: Lock {
    private var mutex = pthread_mutex_t()

    init() {
        pthread_mutex_init(&mutex, nil)
    }

    func lock() {
        pthread_mutex_lock(&mutex)
    }

    func unlock() {
        pthread_mutex_unlock(&mutex)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }
}

final class SpinLock: Lock {
    private let locker: Lock

    init() {
        if #available(iOS 10.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *) {
            locker = UnfairLock()
        } else {
            locker = Mutex()
        }
    }

    func lock() {
        locker.lock()
    }

    func unlock() {
        locker.unlock()
    }
}

extension SpinLock {
    @inline(__always)
    final func performLocked(_ action: () -> Void) {
        self.lock(); defer { self.unlock() }
        action()
    }

    @inline(__always)
    final func calculateLocked<T>(_ action: () -> T) -> T {
        self.lock(); defer { self.unlock() }
        return action()
    }

    @inline(__always)
    final func calculateLockedOrFail<T>(_ action: () throws -> T) throws -> T {
        self.lock(); defer { self.unlock() }
        let result = try action()
        return result
    }
}

extension RecursiveLock : Lock {
    @inline(__always)
    final func performLocked(_ action: () -> Void) {
        self.lock(); defer { self.unlock() }
        action()
    }

    @inline(__always)
    final func calculateLocked<T>(_ action: () -> T) -> T {
        self.lock(); defer { self.unlock() }
        return action()
    }

    @inline(__always)
    final func calculateLockedOrFail<T>(_ action: () throws -> T) throws -> T {
        self.lock(); defer { self.unlock() }
        let result = try action()
        return result
    }
}
