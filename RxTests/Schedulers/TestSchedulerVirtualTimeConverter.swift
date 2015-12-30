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

    private let _resolution: Double

    init(resolution: Double) {
        _resolution = resolution
    }

    public func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime {
        return NSDate(timeIntervalSince1970: RxTimeInterval(virtualTime) * _resolution)
    }

    public func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit {
        return VirtualTimeIntervalUnit(time.timeIntervalSince1970 / _resolution + 0.5)
    }

    public func convertFromVirtualTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval) * _resolution
    }

    public func convertToVirtualTimeInterval(timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit {
        return VirtualTimeIntervalUnit(timeInterval / _resolution + 0.5)
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