//
//  LockOwnerType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 10/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol LockOwnerType : class, Lock {
    var _lock: NSRecursiveLock { get }
}

extension LockOwnerType {
    func lock() {
        _lock.lock()
    }

    func unlock() {
        _lock.unlock()
    }
}
