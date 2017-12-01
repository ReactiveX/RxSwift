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
        return "\(value) @ \(time)"
    }
}

extension Recorded {
    
    /**
     Factory method for an `.next` event recorded at a given time with a given value.
     
     - parameter time: Recorded virtual time the `.next` event occurs.
     - parameter element: Next sequence element.
     - returns: Recorded event in time.
     */
    public static func next<T>(_ time: TestTime, _ element: T) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: time, value: .next(element))
    }
    
    /**
     Factory method for an `.completed` event recorded at a given time.
     
     - parameter time: Recorded virtual time the `.completed` event occurs.
     - parameter type: Sequence elements type.
     - returns: Recorded event in time.
     */
    public static func completed<T>(_ time: TestTime, _ type: T.Type = T.self) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: time, value: .completed)
    }
    
    /**
     Factory method for an `.error` event recorded at a given time with a given error.
     
     - parameter time: Recorded virtual time the `.completed` event occurs.
     */
    public static func error<T>(_ time: TestTime, _ error: Swift.Error, _ type: T.Type = T.self) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: time, value: .error(error))
    }
}

public func == <T: Equatable>(lhs: Recorded<T>, rhs: Recorded<T>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

public func == <T: Equatable>(lhs: Recorded<Event<T>>, rhs: Recorded<Event<T>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

public func == <T: Equatable>(lhs: Recorded<Event<T?>>, rhs: Recorded<Event<T?>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}
