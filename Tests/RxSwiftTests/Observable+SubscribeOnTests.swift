//
//  Observable+SubscribeOnTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSubscribeOnTest : RxTest {
}

extension ObservableSubscribeOnTest {
    func testSubscribeOn_SchedulerSleep() {
        let scheduler = TestScheduler(initialClock: 0)

        var scheduled = 0
        var disposed = 0

        let xs: Observable<Int> = Observable.create { observer in
            scheduled = scheduler.clock
            return Disposables.create {
                disposed = scheduler.clock
            }
        }

        let res = scheduler.start {
            xs.subscribeOn(scheduler)
        }

        XCTAssertEqual(res.events, [

            ])

        XCTAssertEqual(scheduled, 201)
        XCTAssertEqual(disposed, 1001)
    }

    func testSubscribeOn_SchedulerCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            .completed(300)
            ])

        let res = scheduler.start {
            xs.subscribeOn(scheduler)
        }

        XCTAssertEqual(res.events, [
            .completed(300)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(201, 301)
            ])
    }

    func testSubscribeOn_SchedulerError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            .error(300, testError)
            ])

        let res = scheduler.start {
            xs.subscribeOn(scheduler)
        }

        XCTAssertEqual(res.events, [
            .error(300, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(201, 301)
            ])
    }

    func testSubscribeOn_SchedulerDispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            ])

        let res = scheduler.start {
            xs.subscribeOn(scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(210, 2),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(201, 1001)
            ])
    }

    #if TRACE_RESOURCES
        func testSubscribeOnSerialReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).subscribeOn(testScheduler).subscribe()
            testScheduler.start()
        }
        
        func testSubscribeOnSerialReleasesResourcesOnError() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).subscribeOn(testScheduler).subscribe()
            testScheduler.start()
        }
    #endif
}
