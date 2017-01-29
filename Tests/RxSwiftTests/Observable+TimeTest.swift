//
//  Observable+TimeTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxBlocking
import XCTest
import RxTest
#if os(Linux)
import Dispatch
#endif

import struct Foundation.Date

class ObservableTimeTest : RxTest {
    override func setUp() {
        super.setUp()
    }
}

// MARK: Throttle
extension ObservableTimeTest {
    func test_ThrottleTimeSpan_NotLatest_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(250, 3),
            next(310, 4),
            next(350, 5),
            next(410, 6),
            next(450, 7),
            completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = [
            next(210, 2),
            next(410, 6),
            completed(500)
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 500)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NotLatest_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),

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
            next(150, 0),
            completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = [
            completed(500, Int.self)
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
            next(150, 1),
            next(210, 2),
            next(250, 3),
            next(310, 4),
            next(350, 5),
            error(410, testError),
            next(450, 7),
            completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = [
            next(210, 2),
            error(410, testError)
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 410)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NotLatest_NoEnd() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(250, 3),
            next(310, 4),
            next(350, 5),
            next(410, 6),
            next(450, 7),
            ])

        let res = scheduler.start {
            xs.throttle(200, latest: false, scheduler: scheduler)
        }

        let correct = [
            next(210, 2),
            next(410, 6)
        ]

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

        XCTAssertEqualWithAccuracy(0.0, end.timeIntervalSince(start), accuracy: 0.5)
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
extension ObservableTimeTest {

    func test_ThrottleTimeSpan_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(250, 3),
            next(310, 4),
            next(350, 5),
            next(410, 6),
            next(450, 7),
            completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = [
            next(210, 2),
            next(410, 6),
            next(610, 7),
            completed(610)
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 500)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_CompletedAfterDueTime() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(250, 3),
            next(310, 4),
            next(350, 5),
            next(410, 6),
            next(450, 7),
            completed(900)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = [
            next(210, 2),
            next(410, 6),
            next(610, 7),
            completed(900)
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 900)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),

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
            next(150, 0),
            completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = [
            completed(500, Int.self)
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
            next(150, 1),
            next(210, 2),
            next(250, 3),
            next(310, 4),
            next(350, 5),
            error(410, testError),
            next(450, 7),
            completed(500)
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = [
            next(210, 2),
            error(410, testError)
        ]

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 410)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_NoEnd() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(250, 3),
            next(310, 4),
            next(350, 5),
            next(410, 6),
            next(450, 7),
            ])

        let res = scheduler.start {
            xs.throttle(200, scheduler: scheduler)
        }

        let correct = [
            next(210, 2),
            next(410, 6),
            next(610, 7),
        ]
        
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

        XCTAssertEqualWithAccuracy(2, end.timeIntervalSince(start), accuracy: 0.5)
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

// MARK: Sample
extension ObservableTimeTest {
    func testSample_Sampler_SamplerThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])

        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            error(320, testError)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = [
            next(250, 3),
            error(320, testError)
        ]

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
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])

        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = [
            next(250, 3),
            next(320, 6),
            completed(500)
        ]

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
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            next(360, 7),
            completed(400)
            ])

        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = [
            next(250, 3),
            next(320, 6),
            next(500, 7),
            completed(500)
        ]

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
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            completed(300)
            ])

        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = [
            next(250, 3),
            next(320, 4),
            completed(320)
        ]

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
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            error(320, testError)
            ])

        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(300, "baz"),
            completed(400)
            ])

        let res = scheduler.start {
            xs.sample(ys)
        }

        let correct = [
            next(250, 3),
            next(300, 5),
            error(320, testError)
        ]

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
            _ = Observable<Int>.just(1).throttle(0.0, latest: true, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testSamepleReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).throttle(0.0, latest: true, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}

// MARK: Interval
extension ObservableTimeTest {
    func testTimer_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable<Int>.timer(100, scheduler: scheduler)
        }

        let correct = [
            next(300, 0 as Int),
            completed(300)
        ]

        XCTAssertEqual(res.events, correct)
    }

    #if TRACE_RESOURCES
    
        func testTimerReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.timer(100, scheduler: scheduler).subscribe()
            scheduler.start()
        }

    #endif

}

// MARK: Interval
extension ObservableTimeTest {

    func testInterval_TimeSpan_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable<Int64>.interval(100, scheduler: scheduler)
        }

        let correct = [
            next(300, 0 as Int64),
            next(400, 1),
            next(500, 2),
            next(600, 3),
            next(700, 4),
            next(800, 5),
            next(900, 6)
        ]

        XCTAssertEqual(res.events, correct)
    }

    func testInterval_TimeSpan_Zero() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(210) {
            Observable<Int64>.interval(0, scheduler: scheduler)
        }

        let correct = [
            next(201, 0 as Int64),
            next(202, 1),
            next(203, 2),
            next(204, 3),
            next(205, 4),
            next(206, 5),
            next(207, 6),
            next(208, 7),
            next(209, 8),
        ]

        XCTAssertEqual(res.events, correct)
    }

    func testInterval_TimeSpan_Zero_DefaultScheduler() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)

        let observer = PrimitiveMockObserver<Int64>()

        let expectCompleted = expectation(description: "It will complete")

        let d = Observable<Int64>.interval(0, scheduler: scheduler).takeWhile { $0 < 10 } .subscribe(onNext: { t in
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
            Observable<Int64>.interval(1000, scheduler: scheduler)
        }

        let correct: [Recorded<Event<Int64>>] = [

        ]

        XCTAssertEqual(res.events, correct)

    }

    func test_IntervalWithRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

        let start = Date()

        let a = try! Observable<Int64>.interval(1, scheduler: scheduler)
            .take(2)
            .toBlocking()
            .toArray()

        let end = Date()

        XCTAssertEqualWithAccuracy(2, end.timeIntervalSince(start), accuracy: 0.5)
        XCTAssertEqual(a, [0, 1])
    }

}

// MARK: Take
extension ObservableTimeTest {

    func testTake_TakeZero() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230)
        ])

        let res = scheduler.start {
            xs.take(0, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            completed(201)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 201)
            ])
    }

    func testTake_Some() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(240)
            ])

        let res = scheduler.start {
            xs.take(25, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            completed(225)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 225)
            ])
    }

    func testTake_TakeLate() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230),
            ])

        let res = scheduler.start {
            xs.take(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            completed(230)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testTake_TakeError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(0, 0),
            error(210, testError)
            ])

        let res = scheduler.start {
            xs.take(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            error(210, testError),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testTake_TakeNever() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(0, 0),
            ])

        let res = scheduler.start {
            xs.take(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testTake_TakeTwice1() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            completed(270)
            ])

        let res = scheduler.start {
            xs.take(55, scheduler: scheduler).take(35, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(235)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 235)
            ])
    }

    func testTake_TakeDefault() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            completed(270)
            ])

        let res = scheduler.start {
            xs.take(35, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(235)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 235)
            ])
    }


    #if TRACE_RESOURCES
        func testTakeReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).take(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testTakeReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).take(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}

// MARK: Delay Subscription
extension ObservableTimeTest {

    func testDelaySubscription_TimeSpan_Simple() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(50, 42),
            next(60, 43),
            completed(70)
            ])

        let res = scheduler.start {
            xs.delaySubscription(30, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(280, 42),
            next(290, 43),
            completed(300)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 300)
        ])
    }

    func testDelaySubscription_TimeSpan_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(50, 42),
            next(60, 43),
            error(70, testError)
            ])

        let res = scheduler.start {
            xs.delaySubscription(30, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(280, 42),
            next(290, 43),
            error(300, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 300)
            ])
    }

    func testDelaySubscription_TimeSpan_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(50, 42),
            next(60, 43),
            error(70, testError)
            ])

        let res = scheduler.start(291) {
            xs.delaySubscription(30, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(280, 42),
            next(290, 43),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 291)
            ])
    }

    #if TRACE_RESOURCES
        func testDelaySubscriptionReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delaySubscription(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testDelaySubscriptionReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).delaySubscription(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}

// MARK: Skip
extension ObservableTimeTest {
    func testSkip_Zero() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230)
        ])

        let res = scheduler.start {
            xs.skip(0, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            completed(230)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testSkip_Some() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230)
            ])

        let res = scheduler.start {
            xs.skip(15, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(220, 2),
            completed(230)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testSkip_Late() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230)
            ])

        let res = scheduler.start {
            xs.skip(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            completed(230)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testSkip_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            error(210, testError)
            ])

        let res = scheduler.start {
            xs.skip(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testSkip_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            ])

        let res = scheduler.start {
            xs.skip(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    #if TRACE_RESOURCES
        func testSkipReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).skip(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testSskipReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).skip(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}

// MARK: Buffer
extension ObservableTimeTest {
    func testBufferWithTimeOrCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        
        let res = scheduler.start {
            xs.buffer(timeSpan: 70, count: 3, scheduler: scheduler).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(240, EquatableArray([1, 2, 3])),
            next(310, EquatableArray([4])),
            next(370, EquatableArray([5, 6, 7])),
            next(440, EquatableArray([8])),
            next(510, EquatableArray([9])),
            next(580, EquatableArray([])),
            next(600, EquatableArray([])),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testBufferWithTimeOrCount_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            error(600, testError)
            ])
        
        let res = scheduler.start {
            xs.buffer(timeSpan: 70, count: 3, scheduler: scheduler).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(240, EquatableArray([1, 2, 3])),
            next(310, EquatableArray([4])),
            next(370, EquatableArray([5, 6, 7])),
            next(440, EquatableArray([8])),
            next(510, EquatableArray([9])),
            next(580, EquatableArray([])),
            error(600, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testBufferWithTimeOrCount_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start(370) {
            xs.buffer(timeSpan: 70, count: 3, scheduler: scheduler).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(240, EquatableArray([1, 2, 3])),
            next(310, EquatableArray([4])),
            next(370, EquatableArray([5, 6, 7]))
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
            ])
    }

    func testBufferWithTimeOrCount_Default() {
        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
        
        let result = try! Observable.range(start: 1, count: 10, scheduler: backgroundScheduler)
            .buffer(timeSpan: 1000, count: 3, scheduler: backgroundScheduler)
            .skip(1)
            .toBlocking()
            .first()
            
        XCTAssertEqual(result!, [4, 5, 6])
    }

    #if TRACE_RESOURCES
        func testBufferReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).buffer(timeSpan: 0.0, count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testBufferReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).buffer(timeSpan: 0.0, count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}

// MARK: Window
extension ObservableTimeTest {
    func testWindowWithTimeOrCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let window: Observable<Observable<Int>> = xs.window(timeSpan: 70, count: 3, scheduler: scheduler)
            let mappedWithIndex = window.mapWithIndex { (o: Observable<Int>, i: Int) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "0 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "2 5"),
            next(350, "2 6"),
            next(370, "2 7"),
            next(420, "3 8"),
            next(470, "4 9"),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testWindowWithTimeOrCount_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            error(600, testError)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let window: Observable<Observable<Int>> = xs.window(timeSpan: 70, count: 3, scheduler: scheduler)
            let mappedWithIndex = window.mapWithIndex { (o: Observable<Int>, i: Int) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                    }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "0 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "2 5"),
            next(350, "2 6"),
            next(370, "2 7"),
            next(420, "3 8"),
            next(470, "4 9"),
            error(600, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testWindowWithTimeOrCount_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(105, 0),
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start(370) { () -> Observable<String> in
            let window: Observable<Observable<Int>> = xs.window(timeSpan: 70, count: 3, scheduler: scheduler)
            let mappedWithIndex = window.mapWithIndex { (o: Observable<Int>, i: Int) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "0 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "2 5"),
            next(350, "2 6"),
            next(370, "2 7")
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
            ])
    }
    
    func windowWithTimeOrCount_Default() {
        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
        
        let result = try! Observable.range(start: 1, count: 10, scheduler: backgroundScheduler)
            .window(timeSpan: 1000, count: 3, scheduler: backgroundScheduler)
            .mapWithIndex { (o: Observable<Int>, i: Int) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                    }
            }
            .merge()
            .skip(4)
            .toBlocking()
            .first()
    
        XCTAssertEqual(result!, "1 5")
    }

    #if TRACE_RESOURCES
        func testWindowReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).window(timeSpan: 0.0, count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testWindowReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).window(timeSpan: 0.0, count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}


// MARK: Timeout

extension ObservableTimeTest {
    func testTimeout_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs.timeout(200, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            completed(300)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }
    
    func testTimeout_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            error(300, testError)
            ])
        
        let res = scheduler.start {
            xs.timeout(200, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            error(300, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }
    
    func testTimeout_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            ])
        
        let res = scheduler.start {
            xs.timeout(1000, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testTimeout_Duetime_Simple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 42),
            next(25, 43),
            next(40, 44),
            next(50, 45),
            completed(60)
            ])
        
        let res = scheduler.start {
            xs.timeout(30, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(225, 43),
            next(240, 44),
            next(250, 45),
            completed(260)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 260)
            ])
    }
    
    func testTimeout_Duetime_Timeout_Exact() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 42),
            next(20, 43),
            next(50, 44),
            next(60, 45),
            completed(70)
            ])
        
        let res = scheduler.start {
            xs.timeout(30, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            next(250, 44),
            next(260, 45),
            completed(270)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
    }

    func testTimeout_Duetime_Timeout() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 42),
            next(20, 43),
            next(50, 44),
            next(60, 45),
            completed(70)
            ])

        let res = scheduler.start {
            xs.timeout(25, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            error(245, RxError.timeout)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 245)
            ])
    }
    
    func testTimeout_Duetime_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start(370) {
            xs.timeout(40, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
            ])
    }
    
    func testTimeout_TimeoutOccurs_1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(130, 2),
            next(310, 3),
            next(400, 4),
            completed(500)
            ])

        let ys = scheduler.createColdObservable([
            next(50, -1),
            next(200, -2),
            next(310, -3),
            completed(320)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(350, -1),
            next(500, -2),
            next(610, -3),
            completed(620)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 620)
            ])
    }
    
    func testTimeout_TimeoutOccurs_2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(130, 2),
            next(240, 3),
            next(310, 4),
            next(430, 5),
            completed(500)
            ])
        
        let ys = scheduler.createColdObservable([
            next(50, -1),
            next(200, -2),
            next(310, -3),
            completed(320)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(240, 3),
            next(310, 4),
            next(460, -1),
            next(610, -2),
            next(720, -3),
            completed(730)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 410)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(410, 730)
            ])
    }
    
    func testTimeout_TimeoutOccurs_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(130, 2),
            next(240, 3),
            next(310, 4),
            next(430, 5),
            completed(500)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(240, 3),
            next(310, 4)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 410)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(410, 1000)
            ])
    }
    
    func testTimeout_TimeoutOccurs_Completed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            completed(500)
            ])
        
        let ys = scheduler.createColdObservable([
            next(100, -1)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(400, -1),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 1000)
            ])
    }

    func testTimeout_TimeoutOccurs_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            error(500, testError)
            ])

        let ys = scheduler.createColdObservable([
            next(100, -1)
            ])

        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(400, -1),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 1000)
            ])
    }
    
    func testTimeout_TimeoutOccurs_NextIsError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            next(500, 42)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            error(100, testError)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            error(400, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 400)
            ])
    }
    
    func testTimeout_TimeoutNotOccurs_Completed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            completed(250)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            next(100, -1)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(ys.subscriptions, [])
    }
    
    func testTimeout_TimeoutNotOccurs_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            error(250, testError)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            next(100, -1)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            error(250, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(ys.subscriptions, [])
    }
    
    func testTimeout_TimeoutNotOccurs() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(130, 2),
            next(240, 3),
            next(320, 4),
            next(410, 5),
            completed(500)
            ])
        
        let ys = scheduler.createColdObservable([
            next(50, -1),
            next(200, -2),
            next(310, -3),
            completed(320)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(240, 3),
            next(320, 4),
            next(410, 5),
            completed(500)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 500)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            ])
    }

    #if TRACE_RESOURCES
        func testTimeoutReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).timeout(100, other: Observable.empty(), scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testTimeoutReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).timeout(100, other: Observable.empty(), scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif

}

// MARK: Delay
extension ObservableTimeTest {
    
    func testDelay_TimeSpan_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
    
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            next(350, 3),
            next(450, 4),
            completed(550)
            ])
    
        let res = scheduler.start {
            xs.delay(100, scheduler: scheduler)
        }
    
        XCTAssertEqual(res.events, [
            next(350, 2),
            next(450, 3),
            next(550, 4),
            completed(650)
            ])
    
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            next(350, 3),
            next(450, 4),
            completed(550)
            ])
        
        let res = scheduler.start {
            xs.delay(50, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(300, 2),
            next(400, 3),
            next(500, 4),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            next(350, 3),
            next(450, 4),
            completed(550)
            ])
        
        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(400, 2),
            next(500, 3),
            next(600, 4),
            completed(700)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }

    func testDelay_TimeSpan_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError)
            ])

        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            error(250, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testDelay_TimeSpan_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])

        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            completed(400)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testDelay_TimeSpan_Error1() {
        let scheduler = TestScheduler(initialClock: 0)
    
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            next(350, 3),
            next(450, 4),
            error(550, testError)
            ])
    
        let res = scheduler.start {
            xs.delay(50, scheduler: scheduler)
        }
    
        XCTAssertEqual(res.events, [
            next(300, 2),
            next(400, 3),
            next(500, 4),
            error(550, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            next(350, 3),
            next(450, 4),
            error(550, testError)
            ])
        
        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(400, 2),
            next(500, 3),
            error(550, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Real_Simple() {
        let waitForError: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()
    
        let res = s.delay(0.01, scheduler: scheduler)
    
        var array = [Int]()
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
            },
            onCompleted: {
                waitForError.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            s.onNext(2)
            s.onNext(3)
            s.onCompleted()
        }

        try! _ = waitForError.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()
        
        XCTAssertEqual([1, 2, 3], array)
    }
    
    func testDelay_TimeSpan_Real_Error1() {
        let errorReceived: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()

        let res = s.delay(0.01, scheduler: scheduler)
        
        var array = [Int]()

        var error: Swift.Error? = nil
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
            },
            onError: { e in
                error = e
                errorReceived.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            s.onNext(2)
            s.onNext(3)
            s.onError(testError)
        }

        try! errorReceived.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()

        XCTAssertEqual(error! as! TestError, testError)
    }
    
    func testDelay_TimeSpan_Real_Error2() {
        let elementProcessed: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let errorReceived: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()
        
        let res = s.delay(0.01, scheduler: scheduler)
        
        var array = [Int]()
        var err: TestError!
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
                elementProcessed.onCompleted()
            },
            onError: { ex in
                err = ex as! TestError
                errorReceived.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            try! _ = elementProcessed.toBlocking(timeout: 5.0).first()
            s.onError(testError)
        }

        try! _ = errorReceived.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()
        
        XCTAssertEqual([1], array)
        XCTAssertEqual(testError, err)
    }


    func testDelay_TimeSpan_Real_Error3() {
        let elementProcessed: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let errorReceived: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let acknowledged: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()
        
        let res = s.delay(0.01, scheduler: scheduler)
        
        var array = [Int]()
        var err: TestError!
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
                elementProcessed.onCompleted()
                try! _ = acknowledged.toBlocking(timeout: 5.0).first()
            },
            onError: { ex in
                err = ex as! TestError
                errorReceived.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            try! _ = elementProcessed.toBlocking(timeout: 5.0).first()
            s.onError(testError)
            acknowledged.onCompleted()
        }

        try! _ = errorReceived.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()
        
        XCTAssertEqual([1], array)
        XCTAssertEqual(testError, err)
    }
    
    func testDelay_TimeSpan_Positive() {
        let scheduler = TestScheduler(initialClock: 0)
    
        let msgs = [
            next(150, 1),
            next(250, 2),
            next(350, 3),
            next(450, 4),
            completed(550)
        ]
    
        let xs = scheduler.createHotObservable(msgs)
    
        let delay: RxTimeInterval = 42
        let res = scheduler.start {
            xs.delay(delay, scheduler: scheduler)
        }
    
        XCTAssertEqual(res.events,
            msgs.map { Recorded(time: $0.time + Int(delay), value: $0.value) }
                .filter { $0.time > 200 })
    }
    
    func testDelay_TimeSpan_DefaultScheduler() {
        let scheduler = MainScheduler.instance
        XCTAssertEqual(try! Observable.just(1).delay(0.001, scheduler: scheduler).toBlocking(timeout: 5.0).toArray(), [1])
    }

    #if TRACE_RESOURCES
        func testDelayReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delay(100, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testDelayReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).delay(100, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}
