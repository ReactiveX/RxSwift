//
//  Observable+DebugTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/23/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest

class ObservableDebugTest : RxTest {

}

// MARK: debug
extension ObservableDebugTest {
    func testDebug_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 0),
            completed(600)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            return xs.debug()
        }

        XCTAssertEqual(res.events, [
            next(210, 0),
            completed(600)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
        ])
    }

    func testDebug_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 0),
            error(600, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            return xs.debug()
        }

        XCTAssertEqual(res.events, [
            next(210, 0),
            error(600, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
}
