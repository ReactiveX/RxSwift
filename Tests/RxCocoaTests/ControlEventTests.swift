//
//  ControlEventTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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

        let controlProperty = ControlEvent(events: Observable.deferred { () -> Observable<Int> in
            XCTAssertTrue(isMainThread())
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