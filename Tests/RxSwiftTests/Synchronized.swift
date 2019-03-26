//
//  Synchronized.swift
//  Tests
//
//  Created by Krunoslav Zaher on 1/29/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Synchronized<Value> {
  private let _lock = NSRecursiveLock()
  private var _value: Value

  public init(_ value: Value) {
    self._value = value
  }

  public var value: Value {
    self._lock.lock(); defer { self._lock.unlock() }
    return _value
  }

  public func mutate<R>(_ mutate: (inout Value) -> R) -> R {
    self._lock.lock(); defer { self._lock.unlock() }
    return mutate(&_value)
  }
}
