//
//  Observable+ShareReplay1WhileConnectedTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableShareReplay1WhileConnectedTest : RxTest {
}

extension ObservableShareReplay1WhileConnectedTest {
    func testShareReplayLatestWhileConnected_DeadlockImmediatelly() {
        var nEvents = 0

        let observable = Observable.of(0, 1, 2).shareReplayLatestWhileConnected()
        _ = observable.subscribe(onNext: { n in
            nEvents += 1
        })

        XCTAssertEqual(nEvents, 3)
    }

    func testShareReplayLatestWhileConnected_DeadlockEmpty() {
        var nEvents = 0

        let observable = Observable<Int>.empty().shareReplayLatestWhileConnected()
        _ = observable.subscribe(onCompleted: { n in
            nEvents += 1
        })

        XCTAssertEqual(nEvents, 1)
    }

    func testShareReplayLatestWhileConnected_DeadlockError() {
        var nEvents = 0

        let observable = Observable<Int>.error(testError).shareReplayLatestWhileConnected()
        _ = observable.subscribe(onError: { _ in
            nEvents += 1
        })

        XCTAssertEqual(nEvents, 1)
    }

    func testShareReplayLatestWhileConnected_DeadlockErrorAfterN() {
        var nEvents = 0

        let observable = Observable.concat([Observable.of(0, 1, 2), Observable.error(testError)]).shareReplayLatestWhileConnected()
        _ = observable.subscribe(onError: { n in
            nEvents += 1
        })

        XCTAssertEqual(nEvents, 1)
    }

    func testShareReplayLatestWhileConnected_Basic() {
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
            next(370, 6),
            next(390, 7),

            // 2nd batch
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

    func testShareReplayLatestWhileConnected_Error() {
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
            error(365, testError),

            // 2nd batch
            next(450, 9),
            ])

        XCTAssertEqual(res2.events, [
            next(355, 8),
            next(360, 5),
            error(365, testError),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(335, 365),
            Subscription(440, 455)
            ])
    }


    func testShareReplayLatestWhileConnected_FirstDisconnectsThenEmits_Complete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 7),
            next(220, 3),
            next(360, 5),
            completed(365),
            next(370, 6),
            completed(375),
            ])

        var ys: Observable<Int>! = nil

        var subscription1: Disposable! = nil

        let res1 = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) {
            let source = xs.shareReplayLatestWhileConnected()
            ys = Observable.concat([source, source])
        }

        scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
        scheduler.scheduleAt(400) { subscription1.dispose() }

        scheduler.start()

        XCTAssertEqual(res1.events, [
            next(360, 5),
            next(370, 6),
            completed(375)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(335, 365),
            Subscription(365, 375)
            ])
    }

    func testShareReplayLatestWhileConnected_FirstDisconnectsThenEmits_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(110, 7),
            next(220, 3),
            next(360, 5),
            error(365, testError),
            next(370, 6),
            error(375, testError),
            ])

        var ys: Observable<Int>! = nil

        var subscription1: Disposable! = nil

        let res1 = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) {
            let source = xs.shareReplayLatestWhileConnected().catchErrorJustReturn(-1)
            ys = Observable.concat([source, source])
        }

        scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
        scheduler.scheduleAt(400) { subscription1.dispose() }

        scheduler.start()

        XCTAssertEqual(res1.events, [
            next(360, 5),
            next(365, -1),
            next(370, 6),
            next(375, -1),
            completed(375)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(335, 365),
            Subscription(365, 375)
            ])
    }

    #if TRACE_RESOURCES
        func testShareReplayLatestWhileConnectedDisposableDoesntRetainAnything() {

            var disposable: Disposable? = nil

            func performTest() {
                autoreleasepool {
                    disposable = Observable<Int>.just(1).shareReplayLatestWhileConnected().subscribe()
                }
            }

            // warmup cache
            performTest()

            let initialResourceCount = Resources.total

            performTest()
            disposable = disposable!

            XCTAssertEqual(initialResourceCount, Resources.total)
        }

        func testShareReplayLatestWhileConnectedReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).shareReplayLatestWhileConnected().subscribe()
        }

        func testShareReplayLatestWhileConnectedReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).shareReplayLatestWhileConnected().subscribe()
        }

    #endif
}
