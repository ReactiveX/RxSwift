//
//  TestSchedulerVirtualTimeConverter.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

public struct TestSchedulerVirtualTimeConverter : VirtualTimeConverterType {
    public typealias VirtualTimeUnit = Int
    public typealias VirtualTimeIntervalUnit = Int

    public func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime {
        return NSDate(timeIntervalSince1970: RxTimeInterval(virtualTime))
    }

    public func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit {
        return VirtualTimeIntervalUnit(time.timeIntervalSince1970)
    }

    public func convertFromVirtualTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval)
    }

    public func convertToVirtualTimeInterval(timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit {
        return VirtualTimeIntervalUnit(timeInterval)
    }

    public func addVirtualTimeAndTimeInterval(time time: VirtualTimeUnit, timeInterval: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time + timeInterval
    }

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