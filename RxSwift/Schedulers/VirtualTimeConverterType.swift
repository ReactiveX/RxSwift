//
//  VirtualTimeConverterType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol VirtualTimeConverterType {
    typealias VirtualTimeUnit
    typealias VirtualTimeIntervalUnit

    func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime
    func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit

    func convertFromVirtualTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval
    func convertToVirtualTimeInterval(timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit

    func addVirtualTimeAndTimeInterval(time time: VirtualTimeUnit, timeInterval: VirtualTimeIntervalUnit) -> VirtualTimeUnit

    /**
     This is aditional abstraction because `NSDate` is unfortunately not comparable.
     Extending `NSDate` with `Comparable` would be too risky because of possible collisions with other libraries.
    */
    func compareVirtualTime(lhs: VirtualTimeUnit, _ rhs: VirtualTimeUnit) -> VirtualTimeComparison
}

/**
 Virtual time comparison result.

 This is aditional abstraction because `NSDate` is unfortunately not comparable.
 Extending `NSDate` with `Comparable` would be too risky because of possible collisions with other libraries.
*/
public enum VirtualTimeComparison {
    /**
     lhs < rhs.
    */
    case LessThan
    /**
     lhs == rhs.
    */
    case Equal
    /**
     lhs > rhs.
    */
    case GreaterThan

    /**
     lhs < rhs.
    */
    var lessThen: Bool {
        if case .LessThan = self {
            return true
        }

        return false
    }

    /**
    lhs > rhs
    */
    var greaterThan: Bool {
        if case .GreaterThan = self {
            return true
        }

        return false
    }

    /**
     lhs == rhs
    */
    var equal: Bool {
        if case .Equal = self {
            return true
        }

        return false
    }
}
