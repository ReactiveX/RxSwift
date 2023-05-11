//
//  TestSchedulerVirtualTimeConverter.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 12/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/// Converter from virtual time and time interval measured in `Int`s to `Date` and `TimeInterval`.
public struct TestSchedulerVirtualTimeConverter : VirtualTimeConverterType {
    /// Virtual time unit used that represents ticks of virtual clock.
    public typealias VirtualTimeUnit = Int

    /// Virtual time unit used to represent differences of virtual times.
    public typealias VirtualTimeIntervalUnit = Int

    private let resolution: Double

    init(resolution: Double) {
        self.resolution = resolution
    }


    /// Converts virtual time to real time.
    ///
    /// - parameter virtualTime: Virtual time to convert to `Date`.
    /// - returns: `Date` corresponding to virtual time.
    public func convertFromVirtualTime(_ virtualTime: VirtualTimeUnit) -> RxTime {
        Date(timeIntervalSince1970: TimeInterval(virtualTime) * self.resolution)
    }

    /// Converts real time to virtual time.
    ///
    /// - parameter time: `Date` to convert to virtual time.
    /// - returns: Virtual time corresponding to `Date`.
    public func convertToVirtualTime(_ time: RxTime) -> VirtualTimeUnit {
        VirtualTimeIntervalUnit(time.timeIntervalSince1970 / self.resolution + 0.5)
    }

    /// Converts from virtual time interval to `TimeInterval`.
    ///
    /// - parameter virtualTimeInterval: Virtual time interval to convert to `TimeInterval`.
    /// - returns: `TimeInterval` corresponding to virtual time interval.
    public func convertFromVirtualTimeInterval(_ virtualTimeInterval: VirtualTimeIntervalUnit) -> TimeInterval {
        TimeInterval(virtualTimeInterval) * self.resolution
    }

    /// Converts from `TimeInterval` to virtual time interval.
    ///
    /// - parameter timeInterval: `TimeInterval` to convert to virtual time interval.
    /// - returns: Virtual time interval corresponding to time interval.
    public func convertToVirtualTimeInterval(_ timeInterval: TimeInterval) -> VirtualTimeIntervalUnit {
        VirtualTimeIntervalUnit(timeInterval / self.resolution + 0.5)
    }

    /// Adds virtual time and virtual time interval.
    ///
    /// - parameter time: Virtual time.
    /// - parameter offset: Virtual time interval.
    /// - returns: Time corresponding to time offsetted by virtual time interval.
    public func offsetVirtualTime(_ time: VirtualTimeUnit, offset: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        time + offset
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
