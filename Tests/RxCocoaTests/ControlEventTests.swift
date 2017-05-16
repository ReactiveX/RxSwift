//
//  ControlEventTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import XCTest

final class ControlEventTests : RxTest {
    func testObservingIsAlwaysHappeningOnMainQueue() {
        let hotObservable = MainThreadPrimitiveHotObservable<Int>()

        var observedOnMainQueue = false

        let expectSubscribeOffMainQueue = expectation(description: "Did subscribe off main thread")

        let controlProperty = ControlEvent(events: Observable.deferred { () -> Observable<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            observedOnMainQueue = true
            return hotObservable.asObservable()
        })

        doOnBackgroundQueue {
            let d = controlProperty.asObservable().subscribe { n in

            }
            let d2 = controlProperty.subscribe { n in

            }
            doOnMainQueue {
                d.dispose()
                d2.dispose()
                expectSubscribeOffMainQueue.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
        }
        
        XCTAssertTrue(observedOnMainQueue)
    }
}
