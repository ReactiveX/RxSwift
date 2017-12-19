//
//  Observable+ThrottleTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

import struct Foundation.Date

class ObservableThrottleTest : RxTest {
}

extension ObservableThrottleTest {
    func test_ThrottleTimeSpan_NotLatest_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(250, 3),
            .next(310, 4),
            .next(350, 5),
            .next(410, 6),
            .next(450, 7),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(210, 2),
            .next(410, 6),
            .completed(500)
        )

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 500)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NotLatest_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 0),

            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NotLatest_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 0),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = [
            Recorded.completed(500, Int.self)
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 500)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NotLatest_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(250, 3),
            .next(310, 4),
            .next(350, 5),
            .error(410, testError),
            .next(450, 7),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(210, 2),
            .error(410, testError)
        )

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 410)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NotLatest_NoEnd() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(250, 3),
            .next(310, 4),
            .next(350, 5),
            .next(410, 6),
            .next(450, 7),
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(210, 2),
            .next(410, 6)
        )

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NotLatest_WithRealScheduler() {
        #if !os(Linux)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

        let start = Date()

        let a = try! Observable.from([0, 1])
            .throttle(2.0, latest: false, scheduler: scheduler)
            .toBlocking()
            .toArray()

        let end = Date()

        XCTAssertEqual(0.0, end.timeIntervalSince(start), accuracy: 0.5)
        XCTAssertEqual(a, [0])
        #endif
    }

    #if TRACE_RESOURCES
        func testThrottleNotLatestReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).throttle(0.0, latest: false, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testThrottleNotLatestReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).throttle(0.0, latest: false, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}

// MARK: Throttle
extension ObservableThrottleTest {

    func test_ThrottleTimeSpan_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(250, 3),
            .next(310, 4),
            .next(350, 5),
            .next(410, 6),
            .next(450, 7),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(210, 2),
            .next(410, 6),
            .next(610, 7),
            .completed(610)
        )

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 500)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_CompletedAfterDueTime() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(250, 3),
            .next(310, 4),
            .next(350, 5),
            .next(410, 6),
            .next(450, 7),
            .completed(900)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(210, 2),
            .next(410, 6),
            .next(610, 7),
            .completed(900)
        )

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 900)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 0),

            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 0),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = [
            Recorded.completed(500, Int.self)
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 500)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(250, 3),
            .next(310, 4),
            .next(350, 5),
            .error(410, testError),
            .next(450, 7),
            .completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(210, 2),
            .error(410, testError)
        )

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 410)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NoEnd() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(250, 3),
            .next(310, 4),
            .next(350, 5),
            .next(410, 6),
            .next(450, 7),
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = Recorded.events(
            .next(210, 2),
            .next(410, 6),
            .next(610, 7)
        )
        
        XCTAssertEqual(res.events, correct)
        
        let subscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_WithRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

        let start = Date()

        let a = try! Observable.from([0, 1])
            .throttle(2.0, scheduler: scheduler)
            .toBlocking()
            .toArray()

        let end = Date()

        XCTAssertEqual(2, end.timeIntervalSince(start), accuracy: 0.5)
        XCTAssertEqual(a, [0, 1])
    }

    #if TRACE_RESOURCES
        func testThrottleLatestReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).throttle(0.0, latest: true, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testThrottleLatestReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).throttle(0.0, latest: true, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}
