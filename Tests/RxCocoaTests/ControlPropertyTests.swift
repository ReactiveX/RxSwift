//
//  ControlPropertyTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxCocoa
import RxSwift

class ControlPropertyTests : RxTest {
    func testObservingIsAlwaysHappeningOnMainThread() {
        let hotObservable = MainThreadPrimitiveHotObservable<Int>()

        var observedOnMainThread = false

        let expectSubscribeOffMainThread = expectationWithDescription("Did subscribe off main thread")

        let controlProperty = ControlProperty(values: Observable.deferred { () -> Observable<Int> in
            XCTAssertTrue(isMainThread())
            observedOnMainThread = true
            return hotObservable.asObservable()
        }, valueSink: AnyObserver { n in
            
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