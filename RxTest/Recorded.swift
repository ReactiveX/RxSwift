//
//  Recorded.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import Swift

/// Record of a value including the virtual time it was produced on.
public struct Recorded<Value>
    : CustomDebugStringConvertible {

    /// Gets the virtual time the value was produced on.
    public let time: TestTime

    /// Gets the recorded value.
    public let value: Value
    
    public init(time: TestTime, value: Value) {
        self.time = time
        self.value = value
    }
}

extension Recorded {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        "\(self.value) @ \(self.time)"
    }
}

extension Recorded: Equatable where Value: Equatable {
    public static func == (lhs: Recorded<Value>, rhs: Recorded<Value>) -> Bool {
        lhs.time == rhs.time && lhs.value == rhs.value
    }
}
