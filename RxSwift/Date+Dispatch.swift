//
//  Date+Dispatch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/14/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import Foundation

extension DispatchTimeInterval {
    var convertToSecondsFactor: Double {
        switch self {
        case .nanoseconds: return 1_000_000_000.0
        case .microseconds: return 1_000_000.0
        case .milliseconds: return 1000.0
        case .seconds: return 1.0
        case .never: fatalError()
        @unknown default: fatalError()
        }
    }

    func map(_ transform: (Int, Double) -> Int) -> DispatchTimeInterval {
        switch self {
        case let .nanoseconds(value): return .nanoseconds(transform(value, 1_000_000_000.0))
        case let .microseconds(value): return .microseconds(transform(value, 1_000_000.0))
        case let .milliseconds(value): return .milliseconds(transform(value, 1000.0))
        case let .seconds(value): return .seconds(transform(value, 1.0))
        case .never: return .never
        @unknown default: fatalError()
        }
    }

    var isNow: Bool {
        switch self {
        case let .nanoseconds(value), let .microseconds(value), let .milliseconds(value), let .seconds(value): return value == 0
        case .never: return false
        @unknown default: fatalError()
        }
    }

    func reduceWithSpanBetween(earlierDate: Date, laterDate: Date) -> DispatchTimeInterval {
        map { value, factor in
            let interval = laterDate.timeIntervalSince(earlierDate)
            let remainder = Double(value) - interval * factor
            guard remainder > 0 else { return 0 }
            return Int(remainder.rounded(.toNearestOrAwayFromZero))
        }
    }
}

extension Date {
    func addingDispatchInterval(_ dispatchInterval: DispatchTimeInterval) -> Date {
        switch dispatchInterval {
        case let .nanoseconds(value), let .microseconds(value), let .milliseconds(value), let .seconds(value):
            return addingTimeInterval(TimeInterval(value) / dispatchInterval.convertToSecondsFactor)
        case .never: return Date.distantFuture
        @unknown default: fatalError()
        }
    }
}
