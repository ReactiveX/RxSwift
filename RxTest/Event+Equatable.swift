//
//  Event+Equatable.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import class Foundation.NSError

internal func equals<Element: Equatable>(lhs: Event<Element>, rhs: Event<Element>) -> Bool {
    switch (lhs, rhs) {
    case (.completed, .completed): return true
    case let (.error(e1), .error(e2)):
        #if os(Linux)
        return  "\(e1)" == "\(e2)"
        #else
        let error1 = e1 as NSError
        let error2 = e2 as NSError
        
        return error1.domain == error2.domain
            && error1.code == error2.code
            && "\(e1)" == "\(e2)"
        #endif
    case let (.next(v1), .next(v2)): return v1 == v2
    default: return false
    }
}

internal func equals<Element: Equatable>(lhs: Event<Element?>, rhs: Event<Element?>) -> Bool {
    switch (lhs, rhs) {
    case (.completed, .completed): return true
    case let (.error(e1), .error(e2)):
        #if os(Linux)
        return  "\(e1)" == "\(e2)"
        #else
        let error1 = e1 as NSError
        let error2 = e2 as NSError
        
        return error1.domain == error2.domain
            && error1.code == error2.code
            && "\(e1)" == "\(e2)"
        #endif
    case let (.next(v1), .next(v2)): return v1 == v2
    default: return false
    }
}

internal func equals<Element: Equatable>(lhs: SingleEvent<Element>, rhs: SingleEvent<Element>) -> Bool {
    switch (lhs, rhs) {
    case let (.error(e1), .error(e2)):
        #if os(Linux)
        return  "\(e1)" == "\(e2)"
        #else
        let error1 = e1 as NSError
        let error2 = e2 as NSError
        
        return error1.domain == error2.domain
            && error1.code == error2.code
            && "\(e1)" == "\(e2)"
        #endif
    case let (.success(v1), .success(v2)): return v1 == v2
    default: return false
    }
}

internal func equals<Element: Equatable>(lhs: MaybeEvent<Element>, rhs: MaybeEvent<Element>) -> Bool {
    switch (lhs, rhs) {
    case (.completed, .completed): return true
    case let (.error(e1), .error(e2)):
        #if os(Linux)
        return  "\(e1)" == "\(e2)"
        #else
        let error1 = e1 as NSError
        let error2 = e2 as NSError
        
        return error1.domain == error2.domain
            && error1.code == error2.code
            && "\(e1)" == "\(e2)"
        #endif
    case let (.success(v1), .success(v2)): return v1 == v2
    default: return false
    }
}

/// Compares two `CompletableEvent` events.
///
/// In case `Error` events are being compared, they are equal in case their `NSError` representations are equal (domain and code)
/// and their string representations are equal.
extension CompletableEvent: Equatable {
    public static func == (lhs: CompletableEvent, rhs: CompletableEvent) -> Bool {
        switch (lhs, rhs) {
        case (.completed, .completed): return true
        case let (.error(e1), .error(e2)):
            #if os(Linux)
            return  "\(e1)" == "\(e2)"
            #else
            let error1 = e1 as NSError
            let error2 = e2 as NSError

            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(e1)" == "\(e2)"
            #endif
        default: return false
        }
    }
}

extension Event: Equatable where Element: Equatable {
    public static func == (lhs: Event<Element>, rhs: Event<Element>) -> Bool {
        return equals(lhs: lhs, rhs: rhs)
    }
}

extension SingleEvent: Equatable where Element: Equatable {
    public static func == (lhs: SingleEvent<Element>, rhs: SingleEvent<Element>) -> Bool {
        return equals(lhs: lhs, rhs: rhs)
    }
}

extension MaybeEvent: Equatable where Element: Equatable {
    public static func == (lhs: MaybeEvent<Element>, rhs: MaybeEvent<Element>) -> Bool {
        return equals(lhs: lhs, rhs: rhs)
    }
}
