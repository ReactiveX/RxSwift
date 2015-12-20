//
//  XCTest+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
These methods are conceptually extensions of `XCTestCase` but because referencing them in closures would
require specifying `self.*`, they are made global.
*/
//extension XCTestCase {
    /**
    Factory method for an `.Next` event recorded at a given time with a given value.
     
     - parameter time: Recorded virtual time the `.Next` event occurs.
     - parameter element: Next sequence element.
     - returns: Recorded event in time.
    */
    public func next<T>(time: Time, _ element: T) -> Recorded<Event<T>> {
        return Recorded(time: time, event: .Next(element))
    }

    /**
    Factory method for an `.Completed` event recorded at a given time.
     
     - parameter time: Recorded virtual time the `.Completed` event occurs.
     - parameter type: Sequence elements type.
     - returns: Recorded event in time.
    */
    public func completed<T>(time: Time, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        return Recorded(time: time, event: .Completed)
    }

    /**
    Factory method for an `.Error` event recorded at a given time with a given error.
     
     - parameter time: Recorded virtual time the `.Completed` event occurs.
    */
    public func error<T>(time: Time, _ error: ErrorType, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        return Recorded(time: time, event: .Error(error))
    }
//}

import XCTest
/**
Asserts two lists of events are equal. 

Event is considered equal if:
* `Next` events are equal if they have equal corresponding elements.
* `Error` events are equal if errors have same domain and code for `NSError` representation and have equal descriptions.
* `Completed` events are always equal.

- parameter lhs: first set of events.
- parameter lhs: second set of events.
*/
public func XCTAssertEqual<T: Equatable>(lhs: [Event<T>], _ rhs: [Event<T>], file: String = __FILE__, line: Int = __LINE__) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    XCTAssertEqual(leftEquatable, rightEquatable)
}

/*
Asserts two lists of Recorded events are equal.

Recorded events are equal if times are equal and recoreded events are equal.

Event is considered equal if:
* `Next` events are equal if they have equal corresponding elements.
* `Error` events are equal if errors have same domain and code for `NSError` representation and have equal descriptions.
* `Completed` events are always equal.

- parameter lhs: first set of events.
- parameter lhs: second set of events.
*/
public func XCTAssertEqual<T: Equatable>(lhs: [Recorded<Event<T>>], _ rhs: [Recorded<Event<T>>], file: String = __FILE__, line: Int = __LINE__) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    XCTAssertEqual(leftEquatable, rightEquatable)
}