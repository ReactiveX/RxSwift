//
//  XCTest+Rx.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/**
These methods are conceptually extensions of `XCTestCase` but because referencing them in closures would
require specifying `self.*`, they are made global.
*/
//extension XCTestCase {
    /**
    Factory method for an `.next` event recorded at a given time with a given value.

     - parameter time: Recorded virtual time the `.next` event occurs.
     - parameter element: Next sequence element.
     - returns: Recorded event in time.
    */
    public func next<T>(_ time: TestTime, _ element: T) -> Recorded<Event<T>> {
        return Recorded(time: time, value: .next(element))
    }

    /**
    Factory method for an `.completed` event recorded at a given time.

     - parameter time: Recorded virtual time the `.completed` event occurs.
     - parameter type: Sequence elements type.
     - returns: Recorded event in time.
    */
    public func completed<T>(_ time: TestTime, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        return Recorded(time: time, value: .completed)
    }

    /**
    Factory method for an `.error` event recorded at a given time with a given error.

     - parameter time: Recorded virtual time the `.completed` event occurs.
    */
    public func error<T>(_ time: TestTime, _ error: Swift.Error, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        return Recorded(time: time, value: .error(error))
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
public func XCTAssertEqual<T: Equatable>(_ lhs: [Event<T>], _ rhs: [Event<T>], file: StaticString = #file, line: UInt = #line) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    #if os(Linux)
      XCTAssertEqual(leftEquatable, rightEquatable)
    #else
      XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
    #endif
    if leftEquatable == rightEquatable {
        return
    }

    printSequenceDifferences(lhs, rhs, ==)
}

/**
 Asserts two lists of events are equal.

 Event is considered equal if:
 * `Next` events are equal if they have equal corresponding elements.
 * `Error` events are equal if errors have same domain and code for `NSError` representation and have equal descriptions.
 * `Completed` events are always equal.

 - parameter lhs: first set of events.
 - parameter lhs: second set of events.
 */
public func XCTAssertEqual<T: Equatable>(_ lhs: [SingleEvent<T>], _ rhs: [SingleEvent<T>], file: StaticString = #file, line: UInt = #line) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    #if os(Linux)
        XCTAssertEqual(leftEquatable, rightEquatable)
    #else
        XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
    #endif
    if leftEquatable == rightEquatable {
        return
    }

    printSequenceDifferences(lhs, rhs, ==)
}

/**
 Asserts two lists of events are equal.

 Event is considered equal if:
 * `Next` events are equal if they have equal corresponding elements.
 * `Error` events are equal if errors have same domain and code for `NSError` representation and have equal descriptions.
 * `Completed` events are always equal.

 - parameter lhs: first set of events.
 - parameter lhs: second set of events.
 */
public func XCTAssertEqual<T: Equatable>(_ lhs: [MaybeEvent<T>], _ rhs: [MaybeEvent<T>], file: StaticString = #file, line: UInt = #line) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    #if os(Linux)
        XCTAssertEqual(leftEquatable, rightEquatable)
    #else
        XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
    #endif
    if leftEquatable == rightEquatable {
        return
    }

    printSequenceDifferences(lhs, rhs, ==)
}

/**
 Asserts two lists of events are equal.

 Event is considered equal if:
 * `Next` events are equal if they have equal corresponding elements.
 * `Error` events are equal if errors have same domain and code for `NSError` representation and have equal descriptions.
 * `Completed` events are always equal.

 - parameter lhs: first set of events.
 - parameter lhs: second set of events.
 */
public func XCTAssertEqual(_ lhs: [CompletableEvent], _ rhs: [CompletableEvent], file: StaticString = #file, line: UInt = #line) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    #if os(Linux)
        XCTAssertEqual(leftEquatable, rightEquatable)
    #else
        XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
    #endif
    if leftEquatable == rightEquatable {
        return
    }

    printSequenceDifferences(lhs, rhs, ==)
}

/**
Asserts two lists of Recorded events are equal.

Recorded events are equal if times are equal and recoreded events are equal.

Event is considered equal if:
* `Next` events are equal if they have equal corresponding elements.
* `Error` events are equal if errors have same domain and code for `NSError` representation and have equal descriptions.
* `Completed` events are always equal.

- parameter lhs: first set of events.
- parameter lhs: second set of events.
*/
public func XCTAssertEqual<T: Equatable>(_ lhs: [Recorded<Event<T>>], _ rhs: [Recorded<Event<T>>], file: StaticString = #file, line: UInt = #line) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    #if os(Linux)
      XCTAssertEqual(leftEquatable, rightEquatable)
    #else
      XCTAssertEqual(leftEquatable, rightEquatable, file: file, line: line)
    #endif

    if leftEquatable == rightEquatable {
        return
    }

    printSequenceDifferences(lhs, rhs, ==)
}

func printSequenceDifferences<E>(_ lhs: [E], _ rhs: [E], _ equal: (E, E) -> Bool) {
    print("Differences:")
    for (index, elements) in zip(lhs, rhs).enumerated() {
        let l = elements.0
        let r = elements.1
        if !equal(l, r) {
            print("lhs[\(index)]:\n    \(l)")
            print("rhs[\(index)]:\n    \(r)")
        }
    }

    let shortest = min(lhs.count, rhs.count)
    for (index, element) in lhs[shortest ..< lhs.count].enumerated() {
        print("lhs[\(index + shortest)]:\n    \(element)")
    }
    for (index, element) in rhs[shortest ..< rhs.count].enumerated() {
        print("rhs[\(index + shortest)]:\n    \(element)")
    }
}
