//
//  Synchronized.swift
//  Tests
//
//  Created by Krunoslav Zaher on 1/29/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Synchronized<Value> {
    private let lock = NSRecursiveLock()
    private var _value: Value

    init(_ value: Value) {
        _value = value
    }

    var value: Value {
        lock.lock(); defer { self.lock.unlock() }
        return _value
    }

    func mutate<Result>(_ mutate: (inout Value) -> Result) -> Result {
        lock.lock(); defer { self.lock.unlock() }
        return mutate(&_value)
    }
}
