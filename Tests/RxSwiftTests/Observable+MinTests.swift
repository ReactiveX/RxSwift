//
//  Observable+MinTests.swift
//  Tests
//
//  Created by Shai Mishali on 8/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

import XCTest
import RxSwift
import RxTest

#if os(Linux)
    import Glibc
#endif

class ObservableMinTest : RxTest {
}

extension ObservableMinTest {
    func test_minInt() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 80),
            next(180, 140),
            next(230, 160),
            next(270, 40),
            next(340, 111),
            next(380, 1),
            next(390, 111),
            next(450, 40),
            next(470, 270),
            next(560, 271),
            next(580, 11),
            next(600, 269),
            completed(610)
            ])

        let res = scheduler.start { xs.min() }

        XCTAssertEqual(res.events, [
            next(610, 1),
            completed(610)
            ])
    }

    func test_minFloat() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 0.71),
            next(180, 0.709),
            next(230, 0.6),
            next(270, 0.888),
            next(340, 1.45),
            next(380, 8),
            next(390, 8.35),
            next(450, 24.55),
            next(470, 0.44),
            next(560, 0.05),
            next(580, 29.1579),
            next(600, 29.1577),
            completed(610)
            ])

        let res = scheduler.start { xs.min() }

        XCTAssertEqual(res.events, [
            next(610, 0.05),
            completed(610)
            ])
    }

    func test_minClosure() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, "h"),
            next(180, "a"),
            next(230, "hello"),
            next(270, "hello world"),
            next(285, "a"),
            next(340, "encyclopedia"),
            next(380, "very very long string"),
            next(390, "sho"),
            next(450, "short"),
            completed(470)
            ])

        let res = scheduler.start { xs.min { $0.characters.count < $1.characters.count } }

        XCTAssertEqual(res.events, [
            next(470, "a"),
            completed(470)
            ])
    }

    func test_minError() {
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

        let res = scheduler.start() { xs.min() }

        XCTAssertEqual(res.events, [
            error(385, TestError.dummyError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 385)
        ])
    }

    func test_minDisposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 80),
            next(180, 140),
            next(230, 160),
            next(270, 40),
            next(340, 111),
            next(380, 1),
            next(390, 111),
            next(450, 40),
            next(470, 270),
            next(560, 271),
            next(580, 11),
            next(600, 269),
            completed(610)
            ])

        let res = scheduler.start(disposed: 350) { xs.min() }

        XCTAssertEqual(res.events, [])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
            ])
    }

    #if TRACE_RESOURCES
    func testFilterReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).min().subscribe()
    }

    func testFilter1ReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).min().subscribe()
    }
    #endif
}
