//
//  Observable+ReduceTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableReduceTest : RxTest {
}

extension ObservableReduceTest {
    func test_ReduceWithSeed_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])


        let res = scheduler.start { xs.reduce(42, accumulator: +) }

        let correctMessages = [
            next(250, 42),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeed_Return() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 24),
            completed(250)
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +) }

        let correctMessages = [
            next(250, 42 + 24),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeed_Throw() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError),
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +) }

        let correctMessages = [
            error(210, testError, Int.self)
        ]

        let correctSubscriptions = [
            Subscription(200, 210)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeed_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +) }

        let correctMessages: [Recorded<Event<Int>>] = [
        ]

        let correctSubscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeed_Range() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +) }

        let correctMessages = [
            next(260, 42 + 0 + 1 + 2 + 3 + 4),
            completed(260)
        ]

        let correctSubscriptions = [
            Subscription(200, 260)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeed_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])

        let res = scheduler.start {
            xs.reduce(42) { (a: Int, x: Int) throws -> Int in
                if x < 3 {
                    return a + x
                }
                else {
                    throw testError
                }
            }
        }

        let correctMessages = [
            error(240, testError, Int.self)
        ]

        let correctSubscriptions = [
            Subscription(200, 240)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeedAndResult_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +) { $0 * 5 } }

        let correctMessages = [
            next(250, 42 * 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeedAndResult_Return() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 24),
            completed(250)
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +, mapResult: { $0 * 5 }) }

        let correctMessages = [
            next(250, (42 + 24) * 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeedAndResult_Throw() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError),
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +, mapResult: { $0 * 5 }) }

        let correctMessages: [Recorded<Event<Int>>] = [
            error(210, testError, Int.self)
        ]

        let correctSubscriptions = [
            Subscription(200, 210)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeedAndResult_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +, mapResult: { $0 * 5 }) }

        let correctMessages: [Recorded<Event<Int>>] = [
        ]

        let correctSubscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeedAndResult_Range() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +, mapResult: { $0 * 5 }) }

        let correctMessages = [
            next(260, (42 + 0 + 1 + 2 + 3 + 4) * 5),
            completed(260)
        ]

        let correctSubscriptions = [
            Subscription(200, 260)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeedAndResult_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: { a, x in if x < 3 { return a + x } else { throw testError } }, mapResult: { $0 * 5 }) }

        let correctMessages = [
            error(240, testError, Int.self)
        ]

        let correctSubscriptions = [
            Subscription(200, 240)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_ReduceWithSeedAndResult_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])

        let res = scheduler.start { xs.reduce(42, accumulator: +, mapResult: { (_: Int) throws -> Int in throw testError }) }

        let correctMessages = [
            error(260, testError, Int.self)
        ]

        let correctSubscriptions = [
            Subscription(200, 260)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    #if TRACE_RESOURCES
        func testReduceReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).reduce(0, accumulator: +, mapResult: { $0 }).subscribe()
        }

        func testReduceReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).reduce(0, accumulator: +).subscribe()
        }
    #endif
}
