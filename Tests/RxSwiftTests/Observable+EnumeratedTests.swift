//
//  Observable+EnumeratedTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 8/6/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableEnumeratedTest : RxTest {
}

extension ObservableEnumeratedTest {

    func test_Infinite() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, "a"),
            next(220, "b"),
            next(280, "c")
            ])

        let res = scheduler.start {
            xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            next(210, (index: 0, element: "a")),
            next(220, (index: 1, element: "b")),
            next(280, (index: 2, element: "c"))
        ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    func test_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, "a"),
            next(220, "b"),
            next(280, "c"),
            completed(300)
            ])

        let res = scheduler.start {
            xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            next(210, (index: 0, element: "a")),
            next(220, (index: 1, element: "b")),
            next(280, (index: 2, element: "c")),
            completed(300)
        ] as [Recorded<Event<(index: Int, element: String)>>], compareRecordedEvents)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }

    func test_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, "a"),
            next(220, "b"),
            next(280, "c"),
            error(300, testError)
            ])

        let res = scheduler.start {
            xs.enumerated()
        }

        XCTAssertArraysEqual(res.events, [
            next(210, (index: 0, element: "a")),
            next(220, (index: 1, element: "b")),
            next(280, (index: 2, element: "c")),
            error(300, testError)
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

fileprivate func compareRecordedEvents(lhs: Recorded<Event<(index: Int, element: String)>>, rhs: Recorded<Event<(index: Int, element: String)>>) -> Bool {
    return lhs.time == rhs.time && { (lhs: Event<(index: Int, element: String)>, rhs: Event<(index: Int, element: String)>) in
        switch (lhs, rhs) {
        case (.next(let lhs), .next(let rhs)):
            return lhs == rhs
        case (.next, _):
            return false
        case (.error(let lhs), .error(let rhs)):
            return Event<Int>.error(lhs) == Event<Int>.error(rhs)
        case (.error, _):
            return false
        case (.completed, .completed):
            return true
        case (.completed, _):
            return false
        }
    }(lhs.value, rhs.value)
}
