//
//  Observable+SumTests.swift
//  Tests
//
//  Created by Shai Mishali on 8/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

#if os(Linux)
    import Glibc
#endif

class ObservableSumTest : RxTest {
}

extension ObservableSumTest {
    func test_sumInt() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 80),
            next(180, 140),
            next(230, 10),
            next(270, 35),
            next(340, 2000),
            next(380, 1),
            next(450, 271),
            next(470, 4444),
            completed(610)
            ])

        let res = scheduler.start { xs.sum() }

        XCTAssertEqual(res.events, [
            next(610, 6761),
            completed(610)
            ])
    }

    func test_sumDouble() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(200, 0.3),
            next(210, 0.5),
            next(230, 0.1),
            next(270, 0.1),
            next(340, 0.25),
            next(380, 0.25),
            completed(390)
            ])

        let res = scheduler.start { xs.sum() }

        XCTAssertEqual(res.events, [
            next(390, 1.2),
            completed(390)
            ])
    }

    func test_sumClosure() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(230, "eh"),
            next(250, "ll"),
            next(270, " o"),
            next(290, "row"),
            next(310, "dl"),
            next(320, "!"),
            completed(330)
            ])

        let res = scheduler.start { xs.sum(seed: "") { $0 + String($1.characters.reversed()) } }

        XCTAssertEqual(res.events, [
            next(330, "hello world!"),
            completed(330)
            ])
    }

    func test_sumError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 80),
            next(180, 140),
            next(230, 160),
            next(270, 40),
            next(340, 111),
            next(380, 1),
            error(385, TestError.dummyError),
            next(390, 111),
            next(450, 40),
            next(470, 270),
            next(560, 271),
            next(580, 11),
            next(600, 269),
            completed(610)
            ])

        let res = scheduler.start() { xs.sum() }

        XCTAssertEqual(res.events, [
            error(385, TestError.dummyError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 385)
            ])
    }

    func test_sumDisposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 80),
            next(180, 140),
            next(230, 10),
            next(270, 35),
            next(340, 2000),
            next(380, 1),
            next(450, 271),
            next(470, 4444),
            completed(480)
            ])

        let res = scheduler.start(disposed: 350) { xs.sum() }

        XCTAssertEqual(res.events, [])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
            ])
    }

    #if TRACE_RESOURCES
    func testFilterReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).sum().subscribe()
    }

    func testFilter1ReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).sum().subscribe()
    }
    #endif
}

