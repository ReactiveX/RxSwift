//
//  TestVirtualScheduler.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
Scheduler that tests virtual scheduler
*/
class TestVirtualScheduler : VirtualTimeScheduler<TestVirtualSchedulerVirtualTimeConverter> {
    init(initialClock: Int = 0) {
        super.init(initialClock: initialClock, converter: TestVirtualSchedulerVirtualTimeConverter())
    }
}

/**
One virtual unit is equal to 10 seconds.
*/
struct TestVirtualSchedulerVirtualTimeConverter : VirtualTimeConverterType {
    typealias VirtualTimeUnit = Int
    typealias VirtualTimeIntervalUnit = Int

    func convertFromVirtualTime(virtualTime: VirtualTimeUnit) -> RxTime {
        return NSDate(timeIntervalSince1970: RxTimeInterval(virtualTime) * 10.0)
    }

    func convertToVirtualTime(time: RxTime) -> VirtualTimeUnit {
        return Int(time.timeIntervalSince1970 / 10.0)
    }

    func convertFromVirtualTimeInterval(virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval * 10)
    }

    func convertToVirtualTimeInterval(timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit {
        return Int(timeInterval / 10.0)
    }

    func offsetVirtualTime(time time: VirtualTimeUnit, offset: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time + offset
    }

    func compareVirtualTime(lhs: VirtualTimeUnit, _ rhs: VirtualTimeUnit) -> VirtualTimeComparison {
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