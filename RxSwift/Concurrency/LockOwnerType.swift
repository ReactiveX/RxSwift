//
//  LockOwnerType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol LockOwnerType : class, RxLock {
    var _lock: RxRecursiveLock { get }
}

extension LockOwnerType {
    func lock() {
        _lock.lock()
    }

    func unlock() {
        _lock.unlock()
    }
}
