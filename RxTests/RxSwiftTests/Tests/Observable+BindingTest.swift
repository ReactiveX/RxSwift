//
//  Observable+BindingTest.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class ObservableBindingTest : RxTest {
    
}

// refCount
extension ObservableBindingTest {
    func testRefCount_DeadlockSimple() {
        let subject = MySubject<Int>()
        
        var nEvents = 0
        
        let observable = TestConnectableObservable(o: sequenceOf(0, 1, 2), s: subject)
        let d = observable.subscribeNext { n in
            nEvents++
        }

        defer {
            d.dispose()
        }

        observable.connect().dispose()
        
        XCTAssertEqual(nEvents, 3)
    }
    
    func testRefCount_DeadlockErrorAfterN() {
        let subject = MySubject<Int>()
        
        var nEvents = 0
        
        let observable = TestConnectableObservable(o: [sequenceOf(0, 1, 2), failWith(testError)].concat(), s: subject)
        let d = observable.subscribeError { n in
            nEvents++
        }

        defer {
            d.dispose()
        }

        observable.connect().dispose()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testRefCount_DeadlockErrorImmediatelly() {
        let subject = MySubject<Int>()
        
        var nEvents = 0
        
        let observable = TestConnectableObservable(o: failWith(testError), s: subject)
        let d = observable.subscribeError { n in
            nEvents++
        }

        defer {
            d.dispose()
        }

        observable.connect().dispose()
        
        XCTAssertEqual(nEvents, 1)
    }

    func testRefCount_DeadlockEmpty() {
        let subject = MySubject<Int>()
        
        var nEvents = 0
        
        let observable = TestConnectableObservable(o: empty(), s: subject)
        let d = observable.subscribeCompleted {
            nEvents++
        }

        defer {
            d.dispose()
        }

        observable.connect().dispose()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testRefCount_ConnectsOnFirst() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            completed(250)
        ])
        
        let subject = MySubject<Int>()
        
        let conn = TestConnectableObservable(o: xs.asObservable(), s: subject)
        
        let res = scheduler.start { conn.refCount() }
        
        XCTAssertEqual(res.messages, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            completed(250)
        ])
        
        XCTAssertTrue(subject.diposed)
    }
    
    func testRefCount_NotConnected() {
        _ = TestScheduler(initialClock: 0)
        
        var disconnected = false
        var count = 0
        
        let xs: Observable<Int> = deferred {
            count++
            return create { obs in
                return AnonymousDisposable {
                    disconnected = true
                }
            }
        }
        
        let subject = MySubject<Int>()
        
        let conn = TestConnectableObservable(o: xs, s: subject)
        let refd = conn.refCount()
        
        let dis1 = refd.subscribe { _ -> Void in () }
        XCTAssertEqual(1, count)
        XCTAssertEqual(1, subject.subscribeCount)
        XCTAssertFalse(disconnected)
        
        let dis2 = refd.subscribe { _ -> Void in () }
        XCTAssertEqual(1, count)
        XCTAssertEqual(2, subject.subscribeCount)
        XCTAssertFalse(disconnected)
        
        dis1.dispose()
        XCTAssertFalse(disconnected)
        dis2.dispose()
        XCTAssertTrue(disconnected)
        disconnected = false
        
        let dis3 = refd.subscribe { _ -> Void in () }
        XCTAssertEqual(2, count)
        XCTAssertEqual(3, subject.subscribeCount)
        XCTAssertFalse(disconnected)
        
        dis3.dispose()
        XCTAssertTrue(disconnected);
    }
    
    func testRefCount_Error() {
        let xs: Observable<Int> = failWith(testError)
        
        let res = xs.publish().refCount()
        _ = res.subscribe { event in
            switch event {
            case .Next:
                XCTAssertTrue(false)
            case .Error(let error):
                XCTAssertErrorEqual(error, testError)
            case .Completed:
                XCTAssertTrue(false)
            }
        }
        _ = res.subscribe { event in
            switch event {
            case .Next:
                XCTAssertTrue(false)
            case .Error(let error):
                XCTAssertErrorEqual(error, testError)
            case .Completed:
                XCTAssertTrue(false)
            }
        }
    }
    
    func testRefCount_Publish() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            next(270, 7),
            next(280, 8),
            next(290, 9),
            completed(300)
        ])
        
        let res = xs.publish().refCount()
        
        var d1: Disposable!
        let o1: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(215) { d1 = res.subscribe(o1) }
        scheduler.scheduleAt(235) { d1.dispose() }
        
        var d2: Disposable!
        let o2: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(225) { d2 = res.subscribe(o2) }
        scheduler.scheduleAt(275) { d2.dispose() }
        
        var d3: Disposable!
        let o3: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(255) { d3 = res.subscribe(o3) }
        scheduler.scheduleAt(265) { d3.dispose() }
        
        var d4: Disposable!
        let o4: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(285) { d4 = res.subscribe(o4) }
        scheduler.scheduleAt(320) { d4.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(o1.messages, [
            next(220, 2),
            next(230, 3)
        ])
        
        XCTAssertEqual(o2.messages, [
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            next(270, 7)
        ])
        
        XCTAssertEqual(o3.messages, [
            next(260, 6)
        ])
        
        XCTAssertEqual(o4.messages, [
            next(290, 9),
            completed(300)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(215, 275),
            Subscription(285, 300)
        ])
    }
}

// replay
extension ObservableBindingTest {
    func testReplayCount_Basic() {
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
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 5),
            next(450, 6),
            next(450, 7),
            next(520, 11),
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 550),
            Subscription(650, 800)
        ])
    }
    
    func testReplayCount_Error() {
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
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 5),
            next(450, 6),
            next(450, 7),
            next(520, 11),
            next(560, 20),
            error(600, testError),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 600),
            ])
    }
    
    func testReplayCount_Complete() {
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
            completed(600)
            ])
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 5),
            next(450, 6),
            next(450, 7),
            next(520, 11),
            next(560, 20),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 600),
            ])
    }
    
    func testReplayCount_Dispose() {
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
            completed(600)
            ])
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(475) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 5),
            next(450, 6),
            next(450, 7),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 550),
            Subscription(650, 800),
            ])
    }
    
    func testReplayOneCount_Basic() {
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
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 7),
            next(520, 11),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 550),
            Subscription(650, 800)
            ])
    }
    
    func testReplayOneCount_Error() {
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
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 7),
            next(520, 11),
            next(560, 20),
            error(600, testError),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 600),
            ])
    }
    
    func testReplayOneCount_Complete() {
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
            completed(600)
            ])
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 7),
            next(520, 11),
            next(560, 20),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 600),
            ])
    }
    
    func testReplayOneCount_Dispose() {
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
            completed(600)
            ])
        
        var ys: ConnectableObservable<ReplaySubject<Int>>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(475) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(450, 7),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 550),
            Subscription(650, 800),
            ])
    }
}


// shareReplay(1)
extension ObservableBindingTest {
    func _testIdenticalBehaviorOfShareReplayOptimizedAndComposed(action: (transform: (Observable<Int> -> Observable<Int>)) -> Void) {
        action { $0.shareReplay(1) }
        action { $0.replay(1).refCount() }
    }

    func testShareReplay_DeadlockImmediatelly() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
            var nEvents = 0

            let observable = transform(sequenceOf(0, 1, 2))
            _ = observable.subscribeNext { n in
                nEvents++
            }

            XCTAssertEqual(nEvents, 3)
        }
    }

    func testShareReplay_DeadlockEmpty() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
            var nEvents = 0

            let observable = transform(empty())
            _ = observable.subscribeCompleted { n in
                nEvents++
            }

            XCTAssertEqual(nEvents, 1)
        }
    }

    func testShareReplay_DeadlockError() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
            var nEvents = 0

            let observable = transform(failWith(testError))
            _ = observable.subscribeError { _ in
                nEvents++
            }

            XCTAssertEqual(nEvents, 1)
        }
    }

    func testShareReplay1_DeadlockErrorAfterN() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
            var nEvents = 0

            let observable = transform([sequenceOf(0, 1, 2), failWith(testError)].concat())
            _ = observable.subscribeError { n in
                nEvents++
            }
            
            XCTAssertEqual(nEvents, 1)
        }
    }

    func testShareReplay1_Basic() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
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

            let res1: MockObserver<Int> = scheduler.createObserver()
            let res2: MockObserver<Int> = scheduler.createObserver()

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start();

            XCTAssertEqual(res1.messages, [
                // 1rt batch
                next(340, 8),
                next(360, 5),
                next(370, 6),
                next(390, 7),

                // 2nd batch
                next(440, 13),
                next(450, 9)
                ])

            XCTAssertEqual(res2.messages, [
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
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
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

            let res1: MockObserver<Int> = scheduler.createObserver()
            let res2: MockObserver<Int> = scheduler.createObserver()

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start();

            XCTAssertEqual(res1.messages, [
                // 1rt batch
                next(340, 8),
                next(360, 5),
                error(365, testError),

                // 2nd batch
                next(440, 5),
                error(440, testError),
                ])

            XCTAssertEqual(res2.messages, [
                next(355, 8),
                next(360, 5),
                error(365, testError),
                ])

            // unoptimized version of replay subject will make a subscription and kill it immediatelly
            XCTAssertEqual(xs.subscriptions[0], Subscription(335, 365))
            XCTAssertTrue(xs.subscriptions.count <= 2)
            XCTAssertTrue(xs.subscriptions.count == 1 || xs.subscriptions[1] == Subscription(440, 440))
        }
    }

    func testShareReplay1_Completed() {
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

            let res1: MockObserver<Int> = scheduler.createObserver()
            let res2: MockObserver<Int> = scheduler.createObserver()

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start();

            XCTAssertEqual(res1.messages, [
                // 1rt batch
                next(340, 8),
                next(360, 5),
                completed(365),

                // 2nd batch
                next(440, 5),
                completed(440)
                ])

            XCTAssertEqual(res2.messages, [
                next(355, 8),
                next(360, 5),
                completed(365)
                ])

            // unoptimized version of replay subject will make a subscription and kill it immediatelly
            XCTAssertEqual(xs.subscriptions[0], Subscription(335, 365))
            XCTAssertTrue(xs.subscriptions.count <= 2)
            XCTAssertTrue(xs.subscriptions.count == 1 || xs.subscriptions[1] == Subscription(440, 440))
        }
    }

    func testShareReplay1_Canceled() {
        _testIdenticalBehaviorOfShareReplayOptimizedAndComposed { transform in
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

            let res1: MockObserver<Int> = scheduler.createObserver()
            let res2: MockObserver<Int> = scheduler.createObserver()

            scheduler.scheduleAt(Defaults.created) { ys = transform(xs.asObservable()) }

            scheduler.scheduleAt(335) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(400) { subscription1.dispose() }

            scheduler.scheduleAt(355) { subscription2 = ys.subscribe(res2) }
            scheduler.scheduleAt(415) { subscription2.dispose() }

            scheduler.scheduleAt(440) { subscription1 = ys.subscribe(res1) }
            scheduler.scheduleAt(455) { subscription1.dispose() }

            scheduler.start();

            XCTAssertEqual(res1.messages, [
                // 1rt batch
                completed(365),

                // 2nd batch
                completed(440)
                ])

            XCTAssertEqual(res2.messages, [
                completed(365)
                ])

            // unoptimized version of replay subject will make a subscription and kill it immediatelly
            XCTAssertEqual(xs.subscriptions[0], Subscription(335, 365))
            XCTAssertTrue(xs.subscriptions.count <= 2)
            XCTAssertTrue(xs.subscriptions.count == 1 || xs.subscriptions[1] == Subscription(440, 440))
        }
    }
}