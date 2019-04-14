//
//  Observable+TimerTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

import struct Foundation.Date

class ObservableTimerTest : RxTest {
}

extension ObservableTimerTest {
    func testTimer_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable<Int>.timer(.seconds(100), scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(300, 0),
            .completed(300)
        )

        XCTAssertEqual(res.events, correct)
    }

    #if TRACE_RESOURCES
    
        func testTimerReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.timer(.seconds(100), scheduler: scheduler).subscribe()
            scheduler.start()
        }

    #endif

}

extension ObservableTimerTest {

    func testInterval_TimeSpan_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable<Int64>.interval(.seconds(100), scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(300, 0 as Int64),
            .next(400, 1),
            .next(500, 2),
            .next(600, 3),
            .next(700, 4),
            .next(800, 5),
            .next(900, 6)
        )

        XCTAssertEqual(res.events, correct)
    }

    func testInterval_TimeSpan_Zero() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(disposed: 210) {
            Observable<Int64>.interval(.seconds(0), scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(201, 0 as Int64),
            .next(202, 1),
            .next(203, 2),
            .next(204, 3),
            .next(205, 4),
            .next(206, 5),
            .next(207, 6),
            .next(208, 7),
            .next(209, 8)
        )

        XCTAssertEqual(res.events, correct)
    }

    func testInterval_TimeSpan_Zero_DefaultScheduler() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)

        let observer = PrimitiveMockObserver<Int64>()

        let expectCompleted = expectation(description: "It will complete")

        let d = Observable<Int64>.interval(.seconds(0), scheduler: scheduler).takeWhile { $0 < 10 } .subscribe(onNext: { t in
            observer.on(.next(t))
        }, onCompleted: {
            expectCompleted.fulfill()
        })

        defer {
            d.dispose()
        }

        waitForExpectations(timeout: 1.0) { e in
            XCTAssert(e == nil, "Did not complete")
        }

        let cleanResources = expectation(description: "Clean resources")

        _ = scheduler.schedule(()) { _ in
            cleanResources.fulfill()
            return Disposables.create()
        }

        waitForExpectations(timeout: 1.0) { e in
            XCTAssert(e == nil, "Did not clean up")
        }

        XCTAssertTrue(observer.events.count == 10)
    }

    func testInterval_TimeSpan_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable<Int64>.interval(.seconds(1000), scheduler: scheduler)
        }

        let correct: [Recorded<Event<Int64>>] = [

        ]

        XCTAssertEqual(res.events, correct)

    }

    func test_IntervalWithRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

        let start = Date()

        let a = try! Observable<Int64>.interval(.seconds(1), scheduler: scheduler)
            .take(2)
            .toBlocking()
            .toArray()

        let end = Date()

        XCTAssertEqual(2, end.timeIntervalSince(start), accuracy: 0.5)
        XCTAssertEqual(a, [0, 1])
    }

}
