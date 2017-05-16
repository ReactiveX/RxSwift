//
//  TestSchedulerVirtualTimeConverter.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 12/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.Date
import RxSwift

/// Converter from virtual time and time interval measured in `Int`s to `Date` and `NSTimeInterval`.
public struct TestSchedulerVirtualTimeConverter : VirtualTimeConverterType {
    /// Virtual time unit used that represents ticks of virtual clock.
    public typealias VirtualTimeUnit = Int

    /// Virtual time unit used to represent differences of virtual times.
    public typealias VirtualTimeIntervalUnit = Int

    private let _resolution: Double

    init(resolution: Double) {
        _resolution = resolution
    }


    /// Converts virtual time to real time.
    ///
    /// - parameter virtualTime: Virtual time to convert to `Date`.
    /// - returns: `Date` corresponding to virtual time.
    public func convertFromVirtualTime(_ virtualTime: VirtualTimeUnit) -> RxTime {
        return Date(timeIntervalSince1970: RxTimeInterval(virtualTime) * _resolution)
    }

    /// Converts real time to virtual time.
    ///
    /// - parameter time: `Date` to convert to virtual time.
    /// - returns: Virtual time corresponding to `Date`.
    public func convertToVirtualTime(_ time: RxTime) -> VirtualTimeUnit {
        return VirtualTimeIntervalUnit(time.timeIntervalSince1970 / _resolution + 0.5)
    }

    /// Converts from virtual time interval to `NSTimeInterval`.
    ///
    /// - parameter virtualTimeInterval: Virtual time interval to convert to `NSTimeInterval`.
    /// - returns: `NSTimeInterval` corresponding to virtual time interval.
    public func convertFromVirtualTimeInterval(_ virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval) * _resolution
    }

    /// Converts from virtual time interval to `NSTimeInterval`.
    ///
    /// - parameter timeInterval: `NSTimeInterval` to convert to virtual time interval.
    /// - returns: Virtual time interval corresponding to time interval.
    public func convertToVirtualTimeInterval(_ timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit {
        return VirtualTimeIntervalUnit(timeInterval / _resolution + 0.5)
    }

    /// Adds virtual time and virtual time interval.
    ///
    /// - parameter time: Virtual time.
    /// - parameter offset: Virtual time interval.
    /// - returns: Time corresponding to time offsetted by virtual time interval.
    public func offsetVirtualTime(_ time: VirtualTimeUnit, offset: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time + offset
    }

    /// Compares virtual times.
    public func compareVirtualTime(_ lhs: VirtualTimeUnit, _ rhs: VirtualTimeUnit) -> VirtualTimeComparison {
        if lhs < rhs {
            return .lessThan
        }
        else if lhs > rhs {
            return .greaterThan
        }
        else {
            return .equal
        }
    }
}
