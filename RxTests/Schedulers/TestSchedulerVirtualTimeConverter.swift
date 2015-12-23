//
//  TestSchedulerVirtualTimeConverter.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

public class TestSchedulerVirtualTimeConverter : VirtualTimeConverterType {
    public typealias VirtualTimeUnit = Int
    public typealias VirtualTimeIntervalUnit = Int

    public func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime {
        return NSDate(timeIntervalSince1970: RxTimeInterval(virtualTime))
    }

    public func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit {
        return VirtualTimeIntervalUnit(time.timeIntervalSince1970)
    }

    public func convertFromTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval)
    }

    public func convertToTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval)
    }

    public func addVirtualTimeAndTimeInterval(time time: VirtualTimeUnit, timeInterval: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time + timeInterval
    }

    public func nearFuture(time: VirtualTimeUnit) -> VirtualTimeUnit {
        return time + 1
    }
}