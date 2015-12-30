//
//  TestSchedulerVirtualTimeConverter.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
 Converter from virtual time and time interval measured in `Int`s to `NSDate` and `NSTimeInterval`.
*/
public struct TestSchedulerVirtualTimeConverter : VirtualTimeConverterType {
    /**
     Virtual time unit used that represents ticks of virtual clock.
     */
    public typealias VirtualTimeUnit = Int

    /**
     Virtual time unit used to represent differences of virtual times.
     */
    public typealias VirtualTimeIntervalUnit = Int

    private let _resolution: Double

    init(resolution: Double) {
        _resolution = resolution
    }


    /**
     Converts virtual time to real time.

     - parameter virtualTime: Virtual time to convert to `NSDate`.
     - returns: `NSDate` corresponding to virtual time.
     */
    public func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime {
        return NSDate(timeIntervalSince1970: RxTimeInterval(virtualTime) * _resolution)
    }

    /**
     Converts real time to virtual time.

     - parameter time: `NSDate` to convert to virtual time.
     - returns: Virtual time corresponding to `NSDate`.
     */
    public func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit {
        return VirtualTimeIntervalUnit(time.timeIntervalSince1970 / _resolution + 0.5)
    }

    /**
     Converts from virtual time interval to `NSTimeInterval`.

     - parameter virtualTimeInterval: Virtual time interval to convert to `NSTimeInterval`.
     - returns: `NSTimeInterval` corresponding to virtual time interval.
     */
    public func convertFromVirtualTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval) * _resolution
    }

    /**
     Converts from virtual time interval to `NSTimeInterval`.

     - parameter timeInterval: `NSTimeInterval` to convert to virtual time interval.
     - returns: Virtual time interval corresponding to time interval.
     */
    public func convertToVirtualTimeInterval(timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit {
        return VirtualTimeIntervalUnit(timeInterval / _resolution + 0.5)
    }

    /**
     Adds virtual time and virtual time interval.

     - parameter time: Virtual time.
     - parameter offset: Virtual time interval.
     - returns: Time corresponding to time offsetted by virtual time interval.
     */
    public func offsetVirtualTime(time time: VirtualTimeUnit, offset: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time + offset
    }

    /**
     Compares virtual times.
    */
    public func compareVirtualTime(lhs: VirtualTimeUnit, _ rhs: VirtualTimeUnit) -> VirtualTimeComparison {
        if lhs < rhs {
            return .LessThan
        }
        else if lhs > rhs {
            return .GreaterThan
        }
        else {
            return .Equal
        }
    }
}