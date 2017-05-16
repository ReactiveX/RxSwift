//
//  AssumptionsTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import class Foundation.NSNull

final class AssumptionsTest : RxTest {
    
    func testResourceLeaksDetectionIsTurnedOn() {
#if TRACE_RESOURCES
        let startResourceCount = Resources.total
    
        var observable: Observable<Int>! = Observable.just(1)

        XCTAssertTrue(observable != nil)
        XCTAssertEqual(Resources.total, (startResourceCount + 1) as Int32)
        
        observable = nil

        XCTAssertEqual(Resources.total, startResourceCount)
#elseif RELEASE

#else
        XCTAssert(false, "Can't run unit tests in without tracing")
#endif
    }
}
