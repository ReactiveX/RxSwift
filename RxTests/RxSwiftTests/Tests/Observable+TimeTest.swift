
//
//  Observable+TimeTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxBlocking
import XCTest

class ObservableTimeTest : RxTest {
    override func setUp() {
        super.setUp()
    }
}

// MARK: Throttle
extension ObservableTimeTest {
    func test_ThrottleTimeSpan_AllPass() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            completed(400)
            ])

        let res = scheduler.start {
            xs.throttle(20, scheduler)
        }

        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            completed(400)
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 400)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_AllPass_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            error(400, testError)
            ])

        let res = scheduler.start {
            xs.throttle(20, scheduler)
        }

        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            error(400, testError)
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 400)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_AllDrop() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            completed(400)
            ])

        let res = scheduler.start {
            xs.throttle(40, scheduler)
        }

        let correct = [
            next(400, 7),
            completed(400)
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 400)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleTimeSpan_AllDrop_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            error(400, testError)
            ])

        let res = scheduler.start {
            xs.throttle(40, scheduler)
        }

        let correct: [Recorded<Int>] = [
            error(400, testError)
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 400)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            completed(300)
            ])

        let res = scheduler.start {
            xs.throttle(10, scheduler)
        }

        let correct: [Recorded<Int>] = [
            completed(300)
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            error(300, testError)
            ])

        let res = scheduler.start {
            xs.throttle(10, scheduler)
        }

        let correct: [Recorded<Int>] = [
            error(300, testError)
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleNever() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            ])

        let res = scheduler.start {
            xs.throttle(10, scheduler)
        }

        let correct: [Recorded<Int>] = [
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleSimple() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(250, 3),
            next(280, 4),
            completed(300)
            ])

        let res = scheduler.start {
            xs.throttle(20, scheduler)
        }

        let correct: [Recorded<Int>] = [
            next(230, 1),
            next(270, 3),
            next(300, 4),
            completed(300)
        ]

        XCTAssertEqual(res.messages, correct)

        let subscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)
    }

    func test_ThrottleWithRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)

        let start = NSDate()

        let a = try! [just(0), never()].toObservable().concat()
            .throttle(2.0, scheduler)
            .toBlocking()
            .first()

        let end = NSDate()

        XCTAssertEqualWithAccuracy(2, end.timeIntervalSinceDate(start), accuracy: 0.5)
        XCTAssertEqual(a, 0)
    }
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

        let correct: [Recorded<Int>] = [
            next(250, 3),
            error(320, testError)
        ]

        XCTAssertEqual(res.messages, correct)

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

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 6),
            completed(500)
        ]

        XCTAssertEqual(res.messages, correct)

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

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 6),
            next(500, 7),
            completed(500)
        ]

        XCTAssertEqual(res.messages, correct)

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

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 4),
            completed(320)
        ]

        XCTAssertEqual(res.messages, correct)

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

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(300, 5),
            error(320, testError)
        ]

        XCTAssertEqual(res.messages, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }

    func testSampleLatest_Sampler_SamplerThrows() {
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
            xs.sampleLatest(ys)
        }

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            error(320, testError)
        ]

        XCTAssertEqual(res.messages, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }

    func testSampleLatest_Sampler_Simple1() {
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
            xs.sampleLatest(ys)
        }

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 6),
            next(500, 6),
            completed(500)
        ]

        XCTAssertEqual(res.messages, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }

    func testSampleLatest_Sampler_Simple2() {
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
            xs.sampleLatest(ys)
        }

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 6),
            next(500, 7),
            completed(500)
        ]

        XCTAssertEqual(res.messages, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }

    func testSampleLatest_Sampler_Simple3() {
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
            xs.sampleLatest(ys)
        }

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 4),
            completed(320)
        ]

        XCTAssertEqual(res.messages, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }

    func testSampleLatest_Sampler_SourceThrows() {
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
            xs.sampleLatest(ys)
        }

        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(300, 5),
            error(320, testError)
        ]

        XCTAssertEqual(res.messages, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
}

// MARK: Interval
extension ObservableTimeTest {

    func testInterval_TimeSpan_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            interval(100, scheduler)
        }

        let correct: [Recorded<Int64>] = [
            next(300, 0),
            next(400, 1),
            next(500, 2),
            next(600, 3),
            next(700, 4),
            next(800, 5),
            next(900, 6)
        ]

        XCTAssertEqual(res.messages, correct)
    }

    func testInterval_TimeSpan_Zero() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(210) {
            interval(0, scheduler)
        }

        let correct: [Recorded<Int64>] = [
            next(201, 0),
            next(202, 1),
            next(203, 2),
            next(204, 3),
            next(205, 4),
            next(206, 5),
            next(207, 6),
            next(208, 7),
            next(209, 8),
        ]

        XCTAssertEqual(res.messages, correct)
    }

    func testInterval_TimeSpan_Zero_DefaultScheduler() {
        let scheduler = SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)

        let observer = PrimitiveMockObserver<Int64>()

        var lock = OS_SPINLOCK_INIT

        OSSpinLockLock(&lock)

        let d = interval(0, scheduler).takeWhile { $0 < 10 } .subscribe(onNext: { t in
            observer.on(.Next(t))
        }, onCompleted: {
            OSSpinLockUnlock(&lock)
        })

        defer {
            d.dispose()
        }

        OSSpinLockLock(&lock)
        OSSpinLockUnlock(&lock)

        scheduler.schedule(()) { _ in
            OSSpinLockUnlock(&lock)
            return NopDisposable.instance
        }

        // wait until dispatch queue cleans it's resources
        OSSpinLockLock(&lock)

        XCTAssertTrue(observer.messages.count == 10)
    }

    func testInterval_TimeSpan_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            interval(1000, scheduler)
        }

        let correct: [Recorded<Int64>] = [

        ]

        XCTAssertEqual(res.messages, correct)

    }

    func test_IntervalWithRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)

        let start = NSDate()

        let a = try! interval(1, scheduler)
            .take(2)
            .toBlocking()
            .toArray()

        let end = NSDate()

        XCTAssertEqualWithAccuracy(2, end.timeIntervalSinceDate(start), accuracy: 0.5)
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
            xs.take(0, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.take(25, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.take(50, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.take(50, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.take(50, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.take(55, scheduler).take(35, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.take(35, scheduler)
        }

        XCTAssertEqual(res.messages, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(235)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 235)
            ])
    }

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
            xs.delaySubscription(30, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.delaySubscription(30, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.delaySubscription(30, scheduler)
        }

        XCTAssertEqual(res.messages, [
            next(280, 42),
            next(290, 43),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(230, 291)
            ])
    }
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
            xs.skip(0, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.skip(15, scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            xs.skip(50, scheduler)
        }

        XCTAssertEqual(res.messages, [
            completed(230)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testSkip_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: HotObservable<Int> = scheduler.createHotObservable([
            error(210, testError)
            ])

        let res = scheduler.start {
            xs.skip(50, scheduler)
        }

        XCTAssertEqual(res.messages, [
            error(210, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testSkip_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: HotObservable<Int> = scheduler.createHotObservable([
            ])

        let res = scheduler.start {
            xs.skip(50, scheduler)
        }

        XCTAssertEqual(res.messages, [
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
            next(240, EquatableArray([1, 2, 3])),
            next(310, EquatableArray([4])),
            next(370, EquatableArray([5, 6, 7]))
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
            ])
    }

    func testBufferWithTimeOrCount_Default() {
        let backgroundScheduler = SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let result = try! range(1, 10, backgroundScheduler)
            .buffer(timeSpan: 1000, count: 3, scheduler: backgroundScheduler)
            .skip(1)
            .toBlocking()
            .first()
            
        XCTAssertEqual(result!, [4, 5, 6])
    }
    
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
    
    /*
    func testWindowWithTimeOrCount_BasicPeriod() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(240, 3),
            next(270, 4),
            next(320, 5),
            next(360, 6),
            next(390, 7),
            next(410, 8),
            next(460, 9),
            next(470, 10),
            completed(490)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let window: Observable<Observable<Int>> = xs.window(timeSpan: 100, count: 3, scheduler: scheduler)
            let mappedWithIndex = window.mapWithIndex { (o: Observable<Int>, i: Int) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                    }.concat(just("\(i) end"))
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.messages, [
            next(210, "0 2"),
            next(240, "0 3"),
            next(270, "0 4"),
            next(300, "0 end"),
            next(320, "1 5"),
            next(360, "1 6"),
            next(390, "1 7"),
            next(400, "1 end"),
            next(410, "2 8"),
            next(460, "2 9"),
            next(470, "2 10"),
            next(490, "2 end"),
            completed(490)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 490)
            ])
        
    }*/
    
    func windowWithTimeOrCount_Default() {
        let backgroundScheduler = SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let result = try! range(1, 10, backgroundScheduler)
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
    
}