//
//  Observable+ShareReplayScopeTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 5/28/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableShareReplayScopeTests : RxTest {
}

extension ObservableShareReplayScopeTests {
    func test_testDefaultArguments() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(320, 6),
            next(550, 7)
            ])

        var subscription1: Disposable! = nil
        var subscription2: Disposable! = nil
        var subscription3: Disposable! = nil

        let res1 = scheduler.createObserver(Int.self)
        let res2 = scheduler.createObserver(Int.self)
        let res3 = scheduler.createObserver(Int.self)

        var ys: Observable<Int>! = nil

        scheduler.scheduleAt(Defaults.created) { ys = xs.share() }

        scheduler.scheduleAt(200) { subscription1 = ys.subscribe(res1) }
        scheduler.scheduleAt(300) { subscription2 = ys.subscribe(res2) }

        scheduler.scheduleAt(350) { subscription1.dispose() }
        scheduler.scheduleAt(400) { subscription2.dispose() }

        scheduler.scheduleAt(500) { subscription3 = ys.subscribe(res3) }
        scheduler.scheduleAt(600) { subscription3.dispose() }

        scheduler.start()

        XCTAssertEqual(res1.events, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(320, 6)
            ])

        let replayedEvents2 = (0 ..< 0).map { next(300, 6 - 0 + $0) }

        XCTAssertEqual(res2.events, replayedEvents2 + [next(320, 6)])
        XCTAssertEqual(res3.events, [next(550, 7)])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            Subscription(500, 600)
            ])
    }


    func test_forever_receivesCorrectElements() {
        for i in 0 ..< 5 {
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                    next(210, 1),
                    next(220, 2),
                    next(230, 3),
                    next(240, 4),
                    next(250, 5),
                    next(320, 6),
                    next(550, 7)
                ])

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil
            var subscription3: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)
            let res3 = scheduler.createObserver(Int.self)

            var ys: Observable<Int>! = nil

            scheduler.scheduleAt(Defaults.created) { ys = xs.share(replay: i, scope: .forever) }

            scheduler.scheduleAt(200) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(300) { subscription2 = ys.subscribe(res2) }

            scheduler.scheduleAt(350) { subscription1.dispose() }
            scheduler.scheduleAt(400) { subscription2.dispose() }

            scheduler.scheduleAt(500) { subscription3 = ys.subscribe(res3) }
            scheduler.scheduleAt(600) { subscription3.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6)
                ])

            let replayedEvents2 = (0 ..< i).map { next(300, 6 - i + $0) }
            let replayedEvents3 = (0 ..< i).map { next(500, 7 - i + $0) }

            XCTAssertEqual(res2.events, replayedEvents2 + [next(320, 6)])
            XCTAssertEqual(res3.events, replayedEvents3 + [next(550, 7)])

            XCTAssertEqual(xs.subscriptions, [
                Subscription(200, 400),
                Subscription(500, 600)
                ])
        }
    }

    func test_whileConnected_receivesCorrectElements() {
        for i in 0 ..< 5 {
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                next(550, 7)
                ])

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil
            var subscription3: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)
            let res3 = scheduler.createObserver(Int.self)

            var ys: Observable<Int>! = nil

            scheduler.scheduleAt(Defaults.created) { ys = xs.share(replay: i, scope: .whileConnected) }

            scheduler.scheduleAt(200) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(300) { subscription2 = ys.subscribe(res2) }

            scheduler.scheduleAt(350) { subscription1.dispose() }
            scheduler.scheduleAt(400) { subscription2.dispose() }

            scheduler.scheduleAt(500) { subscription3 = ys.subscribe(res3) }
            scheduler.scheduleAt(600) { subscription3.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6)
                ])

            let replayedEvents2 = (0 ..< i).map { next(300, 6 - i + $0) }

            XCTAssertEqual(res2.events, replayedEvents2 + [next(320, 6)])
            XCTAssertEqual(res3.events, [next(550, 7)])

            XCTAssertEqual(xs.subscriptions, [
                Subscription(200, 400),
                Subscription(500, 600)
                ])
        }
    }

    func test_forever_error() {
        for i in 0 ..< 5 {
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                error(330, testError),
                next(340, -1),
                next(550, 7),
                ])

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil
            var subscription3: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)
            let res1_ = scheduler.createObserver(Int.self)
            let res2_ = scheduler.createObserver(Int.self)
            let res3 = scheduler.createObserver(Int.self)

            var ys: Observable<Int>! = nil

            scheduler.scheduleAt(Defaults.created) { ys = xs.share(replay: i, scope: .forever) }

            scheduler.scheduleAt(200) {
                subscription1 = ys.subscribe { event in
                    res1.on(event)
                    switch event {
                    case .error: subscription1 = ys.subscribe(res1_)
                    case .completed: subscription1 = ys.subscribe(res1_)
                    case .next: break
                    }
                }
            }
            scheduler.scheduleAt(300) {
                subscription2 = ys.subscribe { event in
                    res2.on(event)
                    switch event {
                    case .error: subscription2 = ys.subscribe(res2_)
                    case .completed: subscription2 = ys.subscribe(res2_)
                    case .next: break
                    }
                }
            }

            scheduler.scheduleAt(350) { subscription1.dispose() }
            scheduler.scheduleAt(400) { subscription2.dispose() }

            scheduler.scheduleAt(500) { subscription3 = ys.subscribe(res3) }
            scheduler.scheduleAt(600) { subscription3.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                error(330, testError)
                ])

            let replayedEvents1 = (0 ..< i).map { next(330, 7 - i + $0) }
            
            XCTAssertEqual(res1_.events, replayedEvents1 + [error(330, testError)])
            XCTAssertEqual(res2_.events, replayedEvents1 + [error(330, testError)])


            let replayedEvents2 = (0 ..< i).map { next(300, 6 - i + $0) }
            XCTAssertEqual(res2.events, replayedEvents2 + [next(320, 6), error(330, testError)])


            let replayedEvents3 = (0 ..< i).map { next(500, 7 - i + $0) }
            XCTAssertEqual(res3.events, replayedEvents3 + [error(500, testError)])

            XCTAssertEqual(xs.subscriptions, [
                Subscription(200, 330),
                ])
        }
    }

    func test_whileConnected_error() {
        for i in 0 ..< 5 {
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                error(330, testError),
                next(340, -1),
                next(550, 7),
                ])

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil
            var subscription3: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)
            let res1_ = scheduler.createObserver(Int.self)
            let res2_ = scheduler.createObserver(Int.self)
            let res3 = scheduler.createObserver(Int.self)

            var ys: Observable<Int>! = nil

            scheduler.scheduleAt(Defaults.created) { ys = xs.share(replay: i, scope: .whileConnected) }

            scheduler.scheduleAt(200) {
                subscription1 = ys.subscribe { event in
                    res1.on(event)
                    switch event {
                    case .error: subscription1 = ys.subscribe(res1_)
                    case .completed: subscription1 = ys.subscribe(res1_)
                    case .next: break
                    }
                }
            }
            scheduler.scheduleAt(300) {
                subscription2 = ys.subscribe { event in
                    res2.on(event)
                    switch event {
                    case .error: subscription2 = ys.subscribe(res2_)
                    case .completed: subscription2 = ys.subscribe(res2_)
                    case .next: break
                    }
                }
            }

            scheduler.scheduleAt(350) { subscription1.dispose() }
            scheduler.scheduleAt(400) { subscription2.dispose() }

            scheduler.scheduleAt(500) { subscription3 = ys.subscribe(res3) }
            scheduler.scheduleAt(600) { subscription3.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                error(330, testError)
                ])

            XCTAssertEqual(res1_.events, [next(340, -1)])
            XCTAssertEqual(res2_.events, [next(340, -1)])

            let replayedEvents2 = (0 ..< i).map { next(300, 6 - i + $0) }
            XCTAssertEqual(res2.events, replayedEvents2 + [next(320, 6), error(330, testError)])

            XCTAssertEqual(res3.events, [next(550, 7)])
            
            XCTAssertEqual(xs.subscriptions, [
                Subscription(200, 330),
                Subscription(330, 400),
                Subscription(500, 600)
                ])
        }
    }

    func test_forever_completed() {
        for i in 0 ..< 5 {
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                completed(330),
                next(340, -1),
                next(550, 7),
                ])

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil
            var subscription3: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)
            let res1_ = scheduler.createObserver(Int.self)
            let res2_ = scheduler.createObserver(Int.self)
            let res3 = scheduler.createObserver(Int.self)

            var ys: Observable<Int>! = nil

            scheduler.scheduleAt(Defaults.created) { ys = xs.share(replay: i, scope: .forever) }

            scheduler.scheduleAt(200) {
                subscription1 = ys.subscribe { event in
                    res1.on(event)
                    switch event {
                    case .error: subscription1 = ys.subscribe(res1_)
                    case .completed: subscription1 = ys.subscribe(res1_)
                    case .next: break
                    }
                }
            }
            scheduler.scheduleAt(300) {
                subscription2 = ys.subscribe { event in
                    res2.on(event)
                    switch event {
                    case .error: subscription2 = ys.subscribe(res2_)
                    case .completed: subscription2 = ys.subscribe(res2_)
                    case .next: break
                    }
                }
            }

            scheduler.scheduleAt(350) { subscription1.dispose() }
            scheduler.scheduleAt(400) { subscription2.dispose() }

            scheduler.scheduleAt(500) { subscription3 = ys.subscribe(res3) }
            scheduler.scheduleAt(600) { subscription3.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                completed(330)
                ])

            let replayedEvents1 = (0 ..< i).map { next(330, 7 - i + $0) }

            XCTAssertEqual(res1_.events, replayedEvents1 + [completed(330)])
            XCTAssertEqual(res2_.events, replayedEvents1 + [completed(330)])


            let replayedEvents2 = (0 ..< i).map { next(300, 6 - i + $0) }
            XCTAssertEqual(res2.events, replayedEvents2 + [next(320, 6), completed(330)])


            let replayedEvents3 = (0 ..< i).map { next(500, 7 - i + $0) }
            XCTAssertEqual(res3.events, replayedEvents3 + [completed(500)])

            XCTAssertEqual(xs.subscriptions, [
                Subscription(200, 330),
                ])
        }
    }

    func test_whileConnected_completed() {
        for i in 0 ..< 5 {
            let scheduler = TestScheduler(initialClock: 0)

            let xs = scheduler.createHotObservable([
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                completed(330),
                next(340, -1),
                next(550, 7),
                ])

            var subscription1: Disposable! = nil
            var subscription2: Disposable! = nil
            var subscription3: Disposable! = nil

            let res1 = scheduler.createObserver(Int.self)
            let res2 = scheduler.createObserver(Int.self)
            let res1_ = scheduler.createObserver(Int.self)
            let res2_ = scheduler.createObserver(Int.self)
            let res3 = scheduler.createObserver(Int.self)

            var ys: Observable<Int>! = nil

            scheduler.scheduleAt(Defaults.created) { ys = xs.share(replay: i, scope: .whileConnected) }

            scheduler.scheduleAt(200) {
                subscription1 = ys.subscribe { event in
                    res1.on(event)
                    switch event {
                    case .error: subscription1 = ys.subscribe(res1_)
                    case .completed: subscription1 = ys.subscribe(res1_)
                    case .next: break
                    }
                }
            }
            scheduler.scheduleAt(300) {
                subscription2 = ys.subscribe { event in
                    res2.on(event)
                    switch event {
                    case .error: subscription2 = ys.subscribe(res2_)
                    case .completed: subscription2 = ys.subscribe(res2_)
                    case .next: break
                    }
                }
            }

            scheduler.scheduleAt(350) { subscription1.dispose() }
            scheduler.scheduleAt(400) { subscription2.dispose() }

            scheduler.scheduleAt(500) { subscription3 = ys.subscribe(res3) }
            scheduler.scheduleAt(600) { subscription3.dispose() }

            scheduler.start()

            XCTAssertEqual(res1.events, [
                next(210, 1),
                next(220, 2),
                next(230, 3),
                next(240, 4),
                next(250, 5),
                next(320, 6),
                completed(330)
                ])

            XCTAssertEqual(res1_.events, [next(340, -1)])
            XCTAssertEqual(res2_.events, [next(340, -1)])

            let replayedEvents2 = (0 ..< i).map { next(300, 6 - i + $0) }
            XCTAssertEqual(res2.events, replayedEvents2 + [next(320, 6), completed(330)])
            
            XCTAssertEqual(res3.events, [next(550, 7)])
            
            XCTAssertEqual(xs.subscriptions, [
                Subscription(200, 330),
                Subscription(330, 400),
                Subscription(500, 600)
                ])
        }
    }

    #if TRACE_RESOURCES
        func testReleasesResourcesOnComplete() {
            for i in 0 ..< 5 {
                _ = Observable<Int>.just(1).share(replay: i, scope: .forever).subscribe()
                _ = Observable<Int>.just(1).share(replay: i, scope: .whileConnected).subscribe()
            }
        }

        func testReleasesResourcesOnError() {
            for i in 0 ..< 5 {
                _ = Observable<Int>.error(testError).share(replay: i, scope: .forever).subscribe()
                _ = Observable<Int>.error(testError).share(replay: i, scope: .whileConnected).subscribe()
            }
        }
    #endif
}
