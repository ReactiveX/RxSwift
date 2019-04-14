//
//  Observable+SampleTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSampleTest : RxTest {
}

extension ObservableSampleTest {
    func testSample_Sampler_SamplerThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .next(240, 3),
            .next(290, 4),
            .next(300, 5),
            .next(310, 6),
            .completed(400)
            ])

        let ys = scheduler.createHotObservable([
            .next(150, ""),
            .next(210, "bar"),
            .next(250, "foo"),
            .next(260, "qux"),
            .error(320, testError)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = Recorded.events(
            .next(250, 3),
            .error(320, testError)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
        ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
        ])
    }

    func testSample_Sampler_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .next(240, 3),
            .next(290, 4),
            .next(300, 5),
            .next(310, 6),
            .completed(400)
            ])

        let ys = scheduler.createHotObservable([
            .next(150, ""),
            .next(210, "bar"),
            .next(250, "foo"),
            .next(260, "qux"),
            .next(320, "baz"),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = Recorded.events(
            .next(250, 3),
            .next(320, 6),
            .completed(500)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }

    func testSample_Sampler_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .next(240, 3),
            .next(290, 4),
            .next(300, 5),
            .next(310, 6),
            .next(360, 7),
            .completed(400)
            ])

        let ys = scheduler.createHotObservable([
            .next(150, ""),
            .next(210, "bar"),
            .next(250, "foo"),
            .next(260, "qux"),
            .next(320, "baz"),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = Recorded.events(
            .next(250, 3),
            .next(320, 6),
            .next(500, 7),
            .completed(500)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }

    func testSample_Sampler_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .next(240, 3),
            .next(290, 4),
            .completed(300)
            ])

        let ys = scheduler.createHotObservable([
            .next(150, ""),
            .next(210, "bar"),
            .next(250, "foo"),
            .next(260, "qux"),
            .next(320, "baz"),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = Recorded.events(
            .next(250, 3),
            .next(320, 4),
            .completed(320)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }

    func testSample_Sampler_SourceThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .next(240, 3),
            .next(290, 4),
            .next(300, 5),
            .next(310, 6),
            .error(320, testError)
            ])

        let ys = scheduler.createHotObservable([
            .next(150, ""),
            .next(210, "bar"),
            .next(250, "foo"),
            .next(260, "qux"),
            .next(300, "baz"),
            .completed(400)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = Recorded.events(
            .next(250, 3),
            .next(300, 5),
            .error(320, testError)
        )

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }

    #if TRACE_RESOURCES
        func testSampleReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).throttle(.seconds(0), latest: true, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testSamepleReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).throttle(.seconds(0), latest: true, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}
