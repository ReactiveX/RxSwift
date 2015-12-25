//
//  XCTest+Rx.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//
//

import Foundation
import RxSwift
import RxTests
import XCTest

func XCTAssertErrorEqual(lhs: ErrorType, _ rhs: ErrorType) {
    let event1: Event<Int> = .Error(lhs)
    let event2: Event<Int> = .Error(rhs)
    
    XCTAssertTrue(event1 == event2)
}

func XCTAssertEqualNSValues(lhs: AnyObject, rhs: AnyObject) {
    let pointerValuesAreEqual = (lhs as? NSValue)?.pointerValue == (rhs as? NSValue)?.pointerValue
    let areEqual = lhs.isEqual(rhs) || pointerValuesAreEqual

    XCTAssertTrue(areEqual)
    if !areEqual {
        print(lhs)
        print(rhs)
    }
}

func XCTAssertEqualAnyObjectArrayOfArrays(lhs: [[AnyObject]], _ rhs: [[AnyObject]]) {
    XCTAssertEqual(lhs, rhs) { lhs, rhs in
        if lhs.count != rhs.count {
            return false
        }

        return zip(lhs, rhs).reduce(true) { acc, n in
            let pointerValuesAreEqual: Bool
            if let firstPointer = (n.0 as? NSValue)?.pointerValue, secondPointer = (n.1 as? NSValue)?.pointerValue {
                pointerValuesAreEqual = firstPointer == secondPointer
            }
            else {
                pointerValuesAreEqual = false
            }
            let res = n.0.isEqual(n.1) || pointerValuesAreEqual
            return acc && res
        }
    }
}

func XCTAssertEqual<T>(lhs: [T], _ rhs: [T], _ comparison: (T, T) -> Bool) {
    XCTAssertEqual(lhs.count, rhs.count)
    let areEqual = zip(lhs, rhs).reduce(true) { (a: Bool, z: (T, T)) in a && comparison(z.0, z.1) }
    XCTAssertTrue(areEqual)
    if (!areEqual) {
        print(lhs)
        print(rhs)
    }
}


func doOnBackgroundThread(action: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), action)
}

func doOnMainThread(action: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), action)
}