//
//  Observable+ScanTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import Foundation
import RxSwift
import RxTest
import XCTest

class ObservableScanTest: RxTest {}

extension ObservableScanTest {
    func testScan_Seed_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(0, 0)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
        ])
    }

    func testScan_Into_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(0, 0)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
        ])
    }

    func testScan_Seed_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            .completed(250)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Into_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
            .completed(250)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Seed_Return() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            .next(220, seed + 2),
            .completed(250)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Into_Accumulate() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
            .next(220, seed + 2),
            .completed(250)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Seed_Throw() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            .error(250, testError)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Into_Throw() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(into: seed) { $0 += $1 }
        }

        XCTAssertEqual(res.events, [
            .error(250, testError)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Seed_SomeData() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        let messages = Recorded.events(
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .next(230, seed + 2 + 3 + 4),
            .next(240, seed + 2 + 3 + 4 + 5),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Into_SomeData() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(into: seed) { $0 += $1 }
        }

        let messages = Recorded.events(
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .next(230, seed + 2 + 3 + 4),
            .next(240, seed + 2 + 3 + 4 + 5),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
    }

    func testScan_Seed_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { a, e throws -> Int in
                if e == 4 {
                    throw testError
                } else {
                    return a + e
                }
            }
        }

        XCTAssertEqual(res.events, [
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .error(230, testError)
        ] as [Recorded<Event<Int>>])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
        ])
    }

    func testScan_Into_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(into: seed) { a, e in
                if e == 4 {
                    throw testError
                } else {
                    a += e
                }
            }
        }

        XCTAssertEqual(res.events, [
            .next(210, seed + 2),
            .next(220, seed + 2 + 3),
            .error(230, testError)
        ] as [Recorded<Event<Int>>])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
        ])
    }

    // Regression test for https://github.com/ReactiveX/RxSwift/issues/2679 :
    // `ScanSink` used to mutate its `accumulate` state directly with no lock,
    // so `.next` events delivered concurrently from multiple threads (for
    // example, a shared `PublishSubject` fed concurrently) could race on the
    // read-modify-write of the accumulator, losing or duplicating values.
    // `PublishSubject` only synchronizes its own bookkeeping, not the actual
    // delivery of events to observers, so two threads calling `onNext`
    // concurrently really can invoke `ScanSink.on(_:)` at the same time.
    func testScan_ConcurrentNextEvents_DoesNotCorruptAccumulator() {
        let iterations = 20_000
        let subject = PublishSubject<Int>()

        let resultsLock = NSLock()
        var observedValues = Set<Int>()
        var duplicateFound = false

        let subscription = subject
            .scan(0) { acc, _ in acc + 1 }
            .subscribe(onNext: { value in
                resultsLock.lock()
                if !observedValues.insert(value).inserted {
                    duplicateFound = true
                }
                resultsLock.unlock()
            })

        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            subject.onNext(1)
        }

        subscription.dispose()

        XCTAssertFalse(duplicateFound, "ScanSink produced a duplicate accumulated value under concurrent .next events, indicating a lost update on its accumulator")
        XCTAssertEqual(observedValues, Set(1 ... iterations), "ScanSink's accumulator should reach every value from 1 to \(iterations) exactly once, even when fed concurrently from multiple threads")
    }

    #if TRACE_RESOURCES
    func testScanReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).scan(0, accumulator: +).subscribe()
    }

    func testScan1ReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).scan(0, accumulator: +).subscribe()
    }

    func testScan2ReleasesResourcesOnError() {
        _ = Observable<Int>.just(1).scan(0, accumulator: { _, _ in throw testError }).subscribe()
    }
    #endif
}
