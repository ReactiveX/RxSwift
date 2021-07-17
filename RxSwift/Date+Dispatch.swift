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
        case .milliseconds: return 1_000.0
        case .seconds: return 1.0
        case .never: fatalError()
        @unknown default: fatalError()
        }
    }
 
    func map(_ transform: (Int, Double) -> Int) -> DispatchTimeInterval {
        switch self {
        case .nanoseconds(let value): return .nanoseconds(transform(value, 1_000_000_000.0))
        case .microseconds(let value): return .microseconds(transform(value, 1_000_000.0))
        case .milliseconds(let value): return .milliseconds(transform(value, 1_000.0))
        case .seconds(let value): return .seconds(transform(value, 1.0))
        case .never: return .never
        @unknown default: fatalError()
        }
    }
    
    func toNanoseconds() -> Int {
        switch self {
        case .nanoseconds(let value): return value
        case .microseconds(let value): return value * 1_000
        case .milliseconds(let value): return value * 1_000_000
        case .seconds(let value): return value * 1_000_000_000
        case .never: fatalError()
        @unknown default: fatalError()
        }
    }
    
    var isNow: Bool {
        switch self {
        case .nanoseconds(let value), .microseconds(let value), .milliseconds(let value), .seconds(let value): return value == 0
        case .never: return false
        @unknown default: fatalError()
        }
    }
    
    internal func reduceWithSpanBetween(earlierDate: Date, laterDate: Date) -> DispatchTimeInterval {
        let interval = laterDate.timeIntervalSince(earlierDate)
        guard interval > 0 else { return .nanoseconds(0) }
        return self.map { value, factor in
            let remainder = Double(value) - interval * factor
            guard remainder > 0 else { return 0 }
            return Int(remainder.rounded(.toNearestOrAwayFromZero))
        }
    }
    
    internal func reduceWithSpanBetween(earlierTime: DispatchTimeInterval, laterTime: DispatchTimeInterval) -> DispatchTimeInterval {
        let interval = Double(laterTime.toNanoseconds() - earlierTime.toNanoseconds()) / 1_000_000_000.0
        guard interval > 0 else { return .nanoseconds(0) }
        let result = self.map { value, factor in
            let remainder = Double(value) - interval * factor
            guard remainder > 0 else { return 0 }
            return Int(remainder.rounded(.toNearestOrAwayFromZero))
        }
        return result
    }
}

extension Date {

    internal func addingDispatchInterval(_ dispatchInterval: DispatchTimeInterval) -> Date {
        switch dispatchInterval {
        case .nanoseconds(let value), .microseconds(let value), .milliseconds(let value), .seconds(let value):
            return self.addingTimeInterval(TimeInterval(value) / dispatchInterval.convertToSecondsFactor)
        case .never: return Date.distantFuture
        @unknown default: fatalError()
        }
    }
    
}

extension TimeInterval {
    
    internal func toDispatchTimeInterval() -> DispatchTimeInterval {
        return .nanoseconds(Int(self * 1_000_000_000))
    }
}
