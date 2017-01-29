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

func returnSomething() -> Observable<AnyObject?> {
    return Observable.just(NSNull())
}

func returnSomething() -> Observable<Int?> {
    return Observable.just(3)
}

final class AssumptionsTest : RxTest {
    
    func testResourceLeaksDetectionIsTurnedOn() {
#if TRACE_RESOURCES
        let startResourceCount = Resources.total
    
        var observable: Observable<Int>! = Observable.just(1)

        XCTAssertTrue(observable != nil)
        XCTAssertEqual(Resources.total, startResourceCount + 1)
        
        observable = nil

        XCTAssertEqual(Resources.total, startResourceCount)
#elseif RELEASE

#else
        XCTAssert(false, "Can't run unit tests in without tracing")
#endif
    }
}
