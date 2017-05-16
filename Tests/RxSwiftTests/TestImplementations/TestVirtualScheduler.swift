//
//  TestVirtualScheduler.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

import struct Foundation.Date

/**
Scheduler that tests virtual scheduler
*/
final class TestVirtualScheduler : VirtualTimeScheduler<TestVirtualSchedulerVirtualTimeConverter> {
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

    func convertFromVirtualTime(_ virtualTime: VirtualTimeUnit) -> RxTime {
        return Date(timeIntervalSince1970: RxTimeInterval(virtualTime) * 10.0)
    }

    func convertToVirtualTime(_ time: RxTime) -> VirtualTimeUnit {
        return Int(time.timeIntervalSince1970 / 10.0)
    }

    func convertFromVirtualTimeInterval(_ virtualTimeInterval: VirtualTimeIntervalUnit) -> RxTimeInterval {
        return RxTimeInterval(virtualTimeInterval * 10)
    }

    func convertToVirtualTimeInterval(_ timeInterval: RxTimeInterval) -> VirtualTimeIntervalUnit {
        return Int(timeInterval / 10.0)
    }

    func offsetVirtualTime(_ time: VirtualTimeUnit, offset: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time + offset
    }

    func compareVirtualTime(_ lhs: VirtualTimeUnit, _ rhs: VirtualTimeUnit) -> VirtualTimeComparison {
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
