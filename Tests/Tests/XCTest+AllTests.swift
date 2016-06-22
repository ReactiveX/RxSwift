//
//  XCTest+AllTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxTests
import XCTest

func XCTAssertErrorEqual(_ lhs: ErrorProtocol, _ rhs: ErrorProtocol) {
    let event1: Event<Int> = .error(lhs)
    let event2: Event<Int> = .error(rhs)
    
    XCTAssertTrue(event1 == event2)
}

func NSValuesAreEqual(_ lhs: AnyObject, _ rhs: AnyObject) -> Bool {
    if let lhsValue = lhs as? NSValue, rhsValue = rhs as? NSValue {
        #if os(Linux)
            return lhsValue.isEqual(rhsValue)
        #else
            return lhsValue.isEqual(rhsValue)
                || lhs.pointerValue == rhs.pointerValue
        #endif
    }
    
    return false
}

func XCTAssertEqualNSValues(_ lhs: AnyObject, rhs: AnyObject) {
    let areEqual = NSValuesAreEqual(lhs, rhs)
    XCTAssertTrue(areEqual)
    if !areEqual {
        print(lhs)
        print(rhs)
    }
}

func XCTAssertEqualAnyObjectArrayOfArrays(_ lhs: [[AnyObject]], _ rhs: [[AnyObject]]) {
    XCTAssertEqual(lhs, rhs) { lhs, rhs in
        if lhs.count != rhs.count {
            return false
        }

        return zip(lhs, rhs).reduce(true) { acc, n in
            let res = (n.0 as! NSObject).isEqual(n.1) || NSValuesAreEqual(n.0, n.1)
            return acc && res
        }
    }
}

func XCTAssertEqual<T>(_ lhs: [T], _ rhs: [T], _ comparison: (T, T) -> Bool) {
    XCTAssertEqual(lhs.count, rhs.count)
    let areEqual = zip(lhs, rhs).reduce(true) { (a: Bool, z: (T, T)) in a && comparison(z.0, z.1) }
    XCTAssertTrue(areEqual)
    if (!areEqual) {
        print(lhs)
        print(rhs)
    }
}


func doOnBackgroundThread(_ action: () -> ()) {
    DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async(execute: action)
}

func doOnMainThread(_ action: () -> ()) {
    DispatchQueue.main.async(execute: action)
}
