//
//  Observable+ShareReplay1Tests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableShareReplay1Test : RxTest {
}

enum ShareReplayVersion {
    case composition
    case optimized
}

extension ObservableShareReplay1Test {
    func _testIdenticalBehaviorOfShareReplayOptimizedAndComposed(_ action: @escaping (_ version: ShareReplayVersion,  _ transform: @escaping ((Observable<Int>) -> Observable<Int>)) -> Void) {
        action(.optimized) { ($0.shareReplay(1)) }
        action(.composition) { $0.replay(1).refCount() }
    }

    func testShareReplay_DeadlockImmediatelly() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { _, transform in
            var nEvents = 0

            let observable = transform(Observable.of(0, 1, 2))
            _ = observable.subscribe(onNext: { n in
                nEvents += 1
            })

            XCTAssertEqual(nEvents, 3)
        }
    }

    func testShareReplay_DeadlockEmpty() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { _, transform in
            var nEvents = 0

            let observable = transform(Observable.empty())
            _ = observable.subscribe(onCompleted: { n in
                nEvents += 1
            })

            XCTAssertEqual(nEvents, 1)
        }
    }

    func testShareReplay_DeadlockError() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { _, transform in
            var nEvents = 0

            let observable = transform(Observable.error(testError))
            _ = observable.subscribe(onError: { _ in
                nEvents += 1
            })

            XCTAssertEqual(nEvents, 1)
        }
    }

    func testShareReplay1_DeadlockErrorAfterN() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { _, transform in
            var nEvents = 0

            let observable = transform(Observable.concat([Observable.of(0, 1, 2), Observable.error(testError)]))
            _ = observable.subscribe(onError: { n in
                nEvents += 1
            })

            XCTAssertEqual(nEvents, 1)
        }
    }

    func testShareReplay1_Basic() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { _, transform in
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(110, 7),
                next(220, 3),
                next(280, 4),
                next(290, 1),
                next(340, 8),
                next(360, 5),
                next(370, 6),
                next(390, 7),
                next(410, 13),
                next(430, 2),
                next(450, 9),
                next(520, 11),
                next(560, 20),
                error(600, testError)
                ])

            var ys: Observable<Int>! = nil

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                // 1rt batch
                next(340, 8),
                next(360, 5),
                next(370, 6),
                next(390, 7),

                // 2nd batch
                next(440, 13),
                next(450, 9)
                ])

            XCTAssertEqual(res2.events, [
                next(355, 8),
                next(360, 5),
                next(370, 6),
                next(390, 7),
                next(410, 13)
                ])

            XCTAssertEqual(xs.subscriptions, [
                Subscription(335, 415),
                Subscription(440, 455)
                ])
        }
    }

    func testShareReplay1_Error() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { version, transform in
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(110, 7),
                next(220, 3),
                next(280, 4),
                next(290, 1),
                next(340, 8),
                next(360, 5),
                error(365, testError),
                next(370, 6),
                next(390, 7),
                next(410, 13),
                next(430, 2),
                next(450, 9),
                next(520, 11),
                next(560, 20),
                ])

            var ys: Observable<Int>! = nil

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                // 1rt batch
                next(340, 8),
                next(360, 5),
                error(365, testError),

                // 2nd batch
                next(440, 5),
                error(440, testError),
                ])

            XCTAssertEqual(res2.events, [
                next(355, 8),
                next(360, 5),
                error(365, testError),
                ])

            // unoptimized version of replay subject will make a subscription and kill it immediatelly
            XCTAssertEqual(xs.subscriptions[0], Subscription(335, 365))

            switch version {
            case .composition:
                XCTAssertTrue(xs.subscriptions.count == 2 && xs.subscriptions[1] == Subscription(440, 440))
            case .optimized:
                XCTAssertTrue(xs.subscriptions.count == 1)
            }
        }
    }

    func testShareReplay1_Completed() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { version, transform in
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(110, 7),
                next(220, 3),
                next(280, 4),
                next(290, 1),
                next(340, 8),
                next(360, 5),
                completed(365),
                next(370, 6),
                next(390, 7),
                next(410, 13),
                next(430, 2),
                next(450, 9),
                next(520, 11),
                next(560, 20),
                ])

            var ys: Observable<Int>! = nil

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                // 1rt batch
                next(340, 8),
                next(360, 5),
                completed(365),

                // 2nd batch
                next(440, 5),
                completed(440)
                ])

            XCTAssertEqual(res2.events, [
                next(355, 8),
                next(360, 5),
                completed(365)
                ])

            XCTAssertEqual(xs.subscriptions[0], Subscription(335, 365))

            // unoptimized version of replay subject will make a subscription and kill it immediatelly
            switch version {
            case .composition:
                XCTAssertTrue(xs.subscriptions.count == 2 && xs.subscriptions[1] == Subscription(440, 440))
            case .optimized:
                XCTAssertTrue(xs.subscriptions.count == 1)
            }
        }
    }

    func testShareReplayLatestWhileConnected_Completed() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(110, 7),
                next(220, 3),
                next(280, 4),
                next(290, 1),
                next(340, 8),
                next(360, 5),
                completed(365),
                next(370, 6),
                next(390, 7),
                next(410, 13),
                next(430, 2),
                next(450, 9),
                next(520, 11),
                next(560, 20),
                ])

            var ys: Observable<Int>! = nil

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)

            scheduler.scheduleAt(Defaults.created) { ys = xs.shareReplayLatestWhileConnected() }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                // 1rt batch
                next(340, 8),
                next(360, 5),
                completed(365),

                // 2nd batch
                next(450, 9),
                ])

            XCTAssertEqual(res2.events, [
                next(355, 8),
                next(360, 5),
                completed(365)
                ])

            XCTAssertEqual(xs.subscriptions, [
                Subscription(335, 365),
                Subscription(440, 455)
                ])
        }
    }


    func testShareReplay1_Canceled() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { version, transform in
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                completed(365),
                next(370, 6),
                next(390, 7),
                next(410, 13),
                next(430, 2),
                next(450, 9),
                next(520, 11),
                next(560, 20),
                ])

            var ys: Observable<Int>! = nil

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                // 1rt batch
                completed(365),

                // 2nd batch
                completed(440)
                ])

            XCTAssertEqual(res2.events, [
                completed(365)
                ])

            XCTAssertEqual(xs.subscriptions[0], Subscription(335, 365))
            
            // unoptimized version of replay subject will make a subscription and kill it immediatelly
            switch version {
            case .composition:
                XCTAssertTrue(xs.subscriptions.count == 2 && xs.subscriptions[1] == Subscription(440, 440))
            case .optimized:
                XCTAssertTrue(xs.subscriptions.count == 1)
            }
        }
    }
    
    #if TRACE_RESOURCES
        func testShareReplayReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).shareReplay(1).subscribe()
        }
        
        func testShareReplayReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).shareReplay(1).subscribe()
        }
    
    #endif
}
