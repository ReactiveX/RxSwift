//
//  Observable+EnumeratedTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 8/6/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest
import XCTest

class ObservableEnumeratedTest: RxTest {}

extension ObservableEnumeratedTest {
    func test_Infinite() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(210, "a"),
            .next(220, "b"),
            .next(280, "c")
        ])

        let res = scheduler.start {
            xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            .next(210, (index: 0, element: "a")),
            .next(220, (index: 1, element: "b")),
            .next(280, (index: 2, element: "c"))
        ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
        ])
    }

    func test_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(210, "a"),
            .next(220, "b"),
            .next(280, "c"),
            .completed(300)
        ])

        let res = scheduler.start {
            xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            .next(210, (index: 0, element: "a")),
            .next(220, (index: 1, element: "b")),
            .next(280, (index: 2, element: "c")),
            .completed(300)
        ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
        ])
    }

    func test_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(210, "a"),
            .next(220, "b"),
            .next(280, "c"),
            .error(300, testError)
        ])

        let res = scheduler.start {
            xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            .next(210, (index: 0, element: "a")),
            .next(220, (index: 1, element: "b")),
            .next(280, (index: 2, element: "c")),
            .error(300, testError)
        ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
        ])
    }

    #if TRACE_RESOURCES
    func testEnumeratedReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).enumerated().subscribe()
    }

    func testEnumeratedReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).enumerated().subscribe()
    }
    #endif
}

private func compareRecordedEvents(lhs: Recorded<Event<(index: Int, element: String)>>, rhs: Recorded<Event<(index: Int, element: String)>>) -> Bool {
    lhs.time == rhs.time && { (lhs: Event<(index: Int, element: String)>, rhs: Event<(index: Int, element: String)>) in
        switch (lhs, rhs) {
        case let (.next(lhs), .next(rhs)):
            lhs == rhs
        case (.next, _):
            false
        case let (.error(lhs), .error(rhs)):
            Event<Int>.error(lhs) == Event<Int>.error(rhs)
        case (.error, _):
            false
        case (.completed, .completed):
            true
        case (.completed, _):
            false
        }
    }(lhs.value, rhs.value)
}
