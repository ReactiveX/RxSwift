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

  public init(_ value: Value) {
    self._value = value
  }

  public var value: Value {
    self.lock.lock(); defer { self.lock.unlock() }
    return _value
  }

  public func mutate<Result>(_ mutate: (inout Value) -> Result) -> Result {
    self.lock.lock(); defer { self.lock.unlock() }
    return mutate(&_value)
  }
}
