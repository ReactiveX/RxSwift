//
//  Observable+DelaySubscriptionTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableDelaySubscriptionTest : RxTest {
}

extension ObservableDelaySubscriptionTest {

    func testDelaySubscription_TimeSpan_Simple() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .next(50, 42),
            .next(60, 43),
            .completed(70)
            ])

        let res = scheduler.start {
            xs.delaySubscription(.seconds(30), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(280, 42),
            .next(290, 43),
            .completed(300)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 300)
        ])
    }

    func testDelaySubscription_TimeSpan_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .next(50, 42),
            .next(60, 43),
            .error(70, testError)
            ])

        let res = scheduler.start {
            xs.delaySubscription(.seconds(30), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(280, 42),
            .next(290, 43),
            .error(300, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 300)
            ])
    }

    func testDelaySubscription_TimeSpan_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .next(50, 42),
            .next(60, 43),
            .error(70, testError)
            ])

        let res = scheduler.start(disposed: 291) {
            xs.delaySubscription(.seconds(30), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(280, 42),
            .next(290, 43),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 291)
            ])
    }

    #if TRACE_RESOURCES
        func testDelaySubscriptionReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delaySubscription(.seconds(35), scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testDelaySubscriptionReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).delaySubscription(.seconds(35), scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}
