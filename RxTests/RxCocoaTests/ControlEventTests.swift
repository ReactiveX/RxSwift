//
//  ControlEventTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/6/15.
//
//

import Foundation
import RxCocoa
import RxSwift
import XCTest

class ControlEventTests : RxTest {
    func testObservingIsAlwaysHappeningOnMainThread() {
        let hotObservable = MainThreadPrimitiveHotObservable<Int>()

        var observedOnMainThread = false

        let expectSubscribeOffMainThread = expectationWithDescription("Did subscribe off main thread")

        let controlProperty = ControlEvent(events: deferred { () -> Observable<Int> in
            XCTAssertTrue(NSThread.isMainThread())
            observedOnMainThread = true
            return hotObservable.asObservable()
        })

        doOnBackgroundThread {
            let d = controlProperty.asObservable().subscribe { n in

            }
            let d2 = controlProperty.subscribe { n in

            }
            doOnMainThread {
                d.dispose()
                d2.dispose()
                expectSubscribeOffMainThread.fulfill()
            }
        }

        waitForExpectationsWithTimeout(1.0) { error in
            XCTAssertNil(error)
        }
        
        XCTAssertTrue(observedOnMainThread)
    }
}