//
//  XCTest+AllTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest
import XCTest
import Dispatch

import class Foundation.NSValue
import class Foundation.NSObject
import struct Foundation.Date

func XCTAssertErrorEqual(_ lhs: Swift.Error, _ rhs: Swift.Error, file: StaticString = #file, line: UInt = #line) {
    let lhsEvent: Event<Int> = .error(lhs)
    let rhsEvent: Event<Int> = .error(rhs)
    
    XCTAssertTrue(lhsEvent == rhsEvent, "expected \(rhsEvent) but received \(lhsEvent)", file: file, line: line)
}

func XCTAssertThrowsErrorEqual<T>(_ expression: @autoclosure () throws -> T, _ expectedError: Error, file: StaticString = #file, line: UInt = #line) {
    XCTAssertThrowsError(expression, file: file, line: line) { actualError in
        XCTAssertErrorEqual(actualError, expectedError, file: file, line: line)
    }
}

func NSValuesAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    if let lhsValue = lhs as? NSValue, let rhsValue = rhs as? NSValue {
        #if os(Linux)
            return lhsValue.isEqual(rhsValue)
        #else
            return lhsValue.isEqual(rhsValue)
                || (lhs as AnyObject).pointerValue == (rhs as AnyObject).pointerValue
        #endif
    }
    
    return false
}

func XCTAssertEqualNSValues(_ lhs: AnyObject, rhs: AnyObject, file: StaticString = #file, line: UInt = #line) {
    let areEqual = NSValuesAreEqual(lhs, rhs)
    XCTAssertTrue(areEqual, file: file, line: line)
    if !areEqual {
        print(lhs)
        print(rhs)
    }
}

func XCTAssertEqualAnyObjectArrayOfArrays(_ lhs: [[Any]], _ rhs: [[Any]], file: StaticString = #file, line: UInt = #line) {
    XCTAssertArraysEqual(lhs, rhs, file: file, line: line) { (lhs: [Any], rhs: [Any]) in
        if lhs.count != rhs.count {
            return false
        }

        return zip(lhs, rhs).reduce(true) { acc, n in
            let res = (n.0 as! NSObject).isEqual(n.1) || NSValuesAreEqual(n.0, n.1)
            return acc && res
        }
    }
}

func XCTAssertEqual<T>(_ lhs: T, _ rhs: T, file: StaticString = #file, line: UInt = #line, _ comparison: (T, T) -> Bool) {
    let areEqual = comparison(lhs, rhs)
    XCTAssertTrue(areEqual, file: file, line: line)
    if (!areEqual) {
        print(lhs)
        print(rhs)
    }
}

func XCTAssertArraysEqual<T>(_ lhs: [T], _ rhs: [T], file: StaticString = #file, line: UInt = #line, _ comparison: (T, T) -> Bool) {
    XCTAssertEqual(lhs.count, rhs.count, file: file, line: line)
    let areEqual = zip(lhs, rhs).reduce(true) { (a: Bool, z: (T, T)) in a && comparison(z.0, z.1) }
    XCTAssertTrue(areEqual, file: file, line: line)
    if (!areEqual || lhs.count != rhs.count) {
        print(lhs)
        print(rhs)
    }
}


func doOnBackgroundQueue(_ action: @escaping () -> ()) {
    DispatchQueue.global(qos: .default).async(execute: action)
}

func doOnMainQueue(_ action: @escaping () -> ()) {
    DispatchQueue.main.async(execute: action)
}
