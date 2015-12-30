//
//  Recorded.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import Swift

/**
Record of a value including the virtual time it was produced on.
*/
public struct Recorded<Element>
    : CustomDebugStringConvertible {

    /**
    Gets the virtual time the value was produced on.
    */
    public let time: TestTime

    /**
    Gets the recorded value.
    */
    public let value: Element
    
    public init(time: TestTime, event: Element) {
        self.time = time
        self.value = event
    }
}

extension Recorded {
    /**
    A textual representation of `self`, suitable for debugging.
    */
    public var debugDescription: String {
        get {
            return "\(value) @ \(time)"
        }
    }
}

func == <T: Equatable>(lhs: Recorded<T>, rhs: Recorded<T>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

func == <T: Equatable>(lhs: Recorded<Event<T>>, rhs: Recorded<Event<T>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}