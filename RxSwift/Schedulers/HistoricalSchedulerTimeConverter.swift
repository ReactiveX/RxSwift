//
//  HistoricalSchedulerTimeConverter.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct HistoricalSchedulerTimeConverter : VirtualTimeConverterType {
    public typealias VirtualTimeUnit = RxTime
    public typealias VirtualTimeIntervalUnit = RxTimeInterval

    public func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime {
        return virtualTime
    }

    public func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit {
        return time
    }

    public func convertFromVirtualTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return virtualTimeInterval
    }

    public func convertToVirtualTimeInterval(timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit {
        return timeInterval
    }

    public func addVirtualTimeAndTimeInterval(time time: VirtualTimeUnit, timeInterval: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time.dateByAddingTimeInterval(timeInterval)
    }

    public func compareVirtualTime(lhs: VirtualTimeUnit, _ rhs: VirtualTimeUnit) -> VirtualTimeComparison {
        switch lhs.compare(rhs) {
        case .OrderedAscending:
            return .LessThan
        case .OrderedSame:
            return .Equal
        case .OrderedDescending:
            return .GreaterThan
        }
    }
}