//
//  Lock.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol RxLock {
    func lock()
    func unlock()
}

// https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20151214/000321.html
typealias RxSpinLock = RxRecursiveLock

extension RxRecursiveLock : RxLock {
    @inline(__always)
    final func performLocked(_ action: () -> Void) {
        lock(); defer { unlock() }
        action()
    }

    @inline(__always)
    final func calculateLocked<T>(_ action: () -> T) -> T {
        lock(); defer { unlock() }
        return action()
    }

    @inline(__always)
    final func calculateLockedOrFail<T>(_ action: () throws -> T) throws -> T {
        lock(); defer { unlock() }
        let result = try action()
        return result
    }
}
