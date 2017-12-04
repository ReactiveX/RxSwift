//
//  Observable+MulticastTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableMulticastTest : RxTest {
}

extension ObservableMulticastTest {
    func testMulticastWhileConnected_connectControlsSourceSubscription() {
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
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(makeSubject: { ReplaySubject.create(bufferSize: 3) }) }
        scheduler.scheduleAt(405, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(430, 2),
            next(450, 9),
            next(520, 11),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 530),
            Subscription(575, 621)
            ])
    }

    func testMulticastWhileConnected_connectFirstThenSubscribe() {
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
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(makeSubject: { ReplaySubject.create(bufferSize: 1) }) }
        scheduler.scheduleAt(470, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(470, 9),
            next(520, 11),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 530),
            Subscription(575, 621)
            ])
    }

    func testMulticastWhileConnected_completed() {
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
            completed(435),
            next(450, 9),
            next(520, 11),
            next(560, 20),
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(makeSubject: { ReplaySubject.create(bufferSize: 1) }) }
        scheduler.scheduleAt(405, action: {
            subscription = ys.do(onCompleted: {
                subscription = ys.subscribe(res)
                _ = ys.connect()
            }).subscribe(res)
        })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(430, 2),
            completed(435),
            next(450, 9),
            next(520, 11),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 435),
            Subscription(435, 530),
            Subscription(575, 621),
            ])
    }

    func testMulticastWhileConnected_error() {
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
            error(435, testError),
            next(450, 9),
            next(520, 11),
            next(560, 20),
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(makeSubject: { ReplaySubject.create(bufferSize: 1) }) }
        scheduler.scheduleAt(405, action: {
            subscription = ys.do(onError: { _ in
                subscription = ys.subscribe(res)
                _ = ys.connect()
            }).subscribe(res)
        })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(430, 2),
            error(435, testError),
            next(450, 9),
            next(520, 11),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 435),
            Subscription(435, 530),
            Subscription(575, 621),
            ])
    }

    func testMulticastForever_connectControlsSourceSubscription() {
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
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(ReplaySubject.create(bufferSize: 3)) }
        scheduler.scheduleAt(405, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(405, 5),
            next(405, 6),
            next(405, 7),
            next(430, 2),
            next(450, 9),
            next(520, 11),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 530),
            Subscription(575, 621)
            ])
    }

    func testMulticastForever_connectFirstThenSubscribe() {
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
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(ReplaySubject.create(bufferSize: 1)) }
        scheduler.scheduleAt(470, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(470, 9),
            next(520, 11),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 530),
            Subscription(575, 621)
            ])
    }

    func testMulticastForever_completed() {
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
            completed(435),
            next(450, 9),
            next(520, 11),
            next(560, 20),
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(ReplaySubject.create(bufferSize: 1)) }
        scheduler.scheduleAt(405, action: {
            subscription = ys.do(onCompleted: {
                subscription = ys.subscribe(res)
                _ = ys.connect()
            }).subscribe(res)
        })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(405, 7),
            next(430, 2),
            next(435, 2),
            completed(435),
            completed(435),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 435),
            Subscription(435, 530),
            Subscription(575, 621),
            ])
    }

    func testMulticastForever_error() {
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
            error(435, testError),
            next(450, 9),
            next(520, 11),
            next(560, 20),
            next(570, 21),
            next(580, 23),
            next(590, 24),
            next(600, 25),
            next(610, 26),
            next(620, 27),
            next(630, 28),
            error(800, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var innerConnection: Disposable! = nil
        var lastConnection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.multicast(ReplaySubject.create(bufferSize: 1)) }
        scheduler.scheduleAt(405, action: {
            subscription = ys.do(onError: { _ in
                subscription = ys.subscribe(res)
                _ = ys.connect()
            }).subscribe(res)
        })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(300) { connection = ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(420) { connection = ys.connect() }
        scheduler.scheduleAt(440) { innerConnection = ys.connect() }
        scheduler.scheduleAt(530) { innerConnection.dispose() }
        scheduler.scheduleAt(575) { lastConnection = ys.connect() }
        scheduler.scheduleAt(590) { connection.dispose() }

        scheduler.scheduleAt(621) { lastConnection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(405, 7),
            next(430, 2),
            next(435, 2),
            error(435, testError),
            error(435, testError),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(420, 435),
            Subscription(435, 530),
            Subscription(575, 621),
            ])
    }

    #if TRACE_RESOURCES
        func testMulticastWhileConnected_ReleasesResourcesOnComplete() {
            let publish = Observable<Int>.just(1).multicast(makeSubject: { PublishSubject() })
            _ = publish.subscribe()
            _ = publish.connect()
        }

        func testMulticastWhileConnected_ReleasesResourcesOnError() {
            let publish = Observable<Int>.error(testError).multicast(makeSubject: { PublishSubject() })
            _ = publish.subscribe()
            _ = publish.connect()
        }

        func testMulticastForever_ReleasesResourcesOnComplete() {
            let publish = Observable<Int>.just(1).multicast(PublishSubject())
            _ = publish.subscribe()
            _ = publish.connect()
        }

        func testMulticastForever_ReleasesResourcesOnError() {
            let publish = Observable<Int>.error(testError).multicast(PublishSubject())
            _ = publish.subscribe()
            _ = publish.connect()
        }
    #endif
}

extension ObservableMulticastTest {
    func testMulticast_Cold_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(40, 0),
            next(90, 1),
            next(150, 2),
            next(210, 3),
            next(240, 4),
            next(270, 5),
            next(330, 6),
            next(340, 7),
            completed(390)
            ])

        let res = scheduler.start {
            xs.multicast({ PublishSubject<Int>() }) { $0 }
        }

        XCTAssertEqual(res.events, [
            next(210, 3),
            next(240, 4),
            next(270, 5),
            next(330, 6),
            next(340, 7),
            completed(390)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
    }

    func testMulticast_Cold_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(40, 0),
            next(90, 1),
            next(150, 2),
            next(210, 3),
            next(240, 4),
            next(270, 5),
            next(330, 6),
            next(340, 7),
            error(390, testError)
            ])

        let res = scheduler.start {
            xs.multicast({ PublishSubject<Int>() }) { $0 }
        }

        XCTAssertEqual(res.events, [
            next(210, 3),
            next(240, 4),
            next(270, 5),
            next(330, 6),
            next(340, 7),
            error(390, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
    }

    func testMulticast_Cold_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(40, 0),
            next(90, 1),
            next(150, 2),
            next(210, 3),
            next(240, 4),
            next(270, 5),
            next(330, 6),
            next(340, 7),
            ])

        let res = scheduler.start {
            xs.multicast({ PublishSubject<Int>() }) { $0 }
        }

        XCTAssertEqual(res.events, [
            next(210, 3),
            next(240, 4),
            next(270, 5),
            next(330, 6),
            next(340, 7),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    func testMulticast_Cold_Zip() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(40, 0),
            next(90, 1),
            next(150, 2),
            next(210, 3),
            next(240, 4),
            next(270, 5),
            next(330, 6),
            next(340, 7),
            completed(390)
            ])

        let res = scheduler.start {
            xs.multicast({ PublishSubject<Int>() }) { Observable.zip($0, $0) { a, b in a + b } }
        }

        XCTAssertEqual(res.events, [
            next(210, 6),
            next(240, 8),
            next(270, 10),
            next(330, 12),
            next(340, 14),
            completed(390)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
    }

    func testMulticast_SubjectSelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(240, 2),
            completed(300)
            ])

        let res = scheduler.start {
            xs.multicast({ () throws -> PublishSubject<Int> in throw testError }) { $0 }
        }

        XCTAssertEqual(res.events, [
            error(200, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            ])
    }

    func testMulticast_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(240, 2),
            completed(300)
            ])

        let res = scheduler.start {
            xs.multicast({ PublishSubject<Int>() }) { _ -> Observable<Int> in throw testError }
        }

        XCTAssertEqual(res.events, [
            error(200, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            ])
    }

    #if TRACE_RESOURCES
        func testMulticastReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).multicast({ PublishSubject<Int>() }) { Observable.zip($0, $0) { a, b in a + b } }.subscribe()
        }

        func testMulticastReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).multicast({ PublishSubject<Int>() }) { Observable.zip($0, $0) { a, b in a + b } }.subscribe()
        }
    #endif
}

// publish
extension ObservableMulticastTest {
    #if TRACE_RESOURCES
        func testPublishReleasesResourcesOnComplete() {
            let publish = Observable<Int>.just(1).publish()
            _ = publish.subscribe()
            _ = publish.connect()
        }

        func testPublishReleasesResourcesOnError() {
            let publish = Observable<Int>.error(testError).publish()
            _ = publish.subscribe()
            _ = publish.connect()
        }
    #endif
}

// refCount
extension ObservableMulticastTest {
    func testRefCount_DeadlockSimple() {
        let subject = MySubject<Int>()

        var nEvents = 0

        let observable = TestConnectableObservable(o: Observable.of(0, 1, 2), s: subject)
        let d = observable.subscribe(onNext: { n in
            nEvents += 1
        })

        defer {
            d.dispose()
        }

        observable.connect().dispose()

        XCTAssertEqual(nEvents, 3)
    }

    func testRefCount_DeadlockErrorAfterN() {
        let subject = MySubject<Int>()

        var nEvents = 0

        let observable = TestConnectableObservable(o: Observable.concat([Observable.of(0, 1, 2), Observable.error(testError)]), s: subject)
        let d = observable.subscribe(onError: { n in
            nEvents += 1
        })

        defer {
            d.dispose()
        }

        observable.connect().dispose()

        XCTAssertEqual(nEvents, 1)
    }

    func testRefCount_DeadlockErrorImmediatelly() {
        let subject = MySubject<Int>()

        var nEvents = 0

        let observable = TestConnectableObservable(o: Observable.error(testError), s: subject)
        let d = observable.subscribe(onError: { n in
            nEvents += 1
        })

        defer {
            d.dispose()
        }

        observable.connect().dispose()

        XCTAssertEqual(nEvents, 1)
    }

    func testRefCount_DeadlockEmpty() {
        let subject = MySubject<Int>()

        var nEvents = 0

        let observable = TestConnectableObservable(o: Observable.empty(), s: subject)
        let d = observable.subscribe(onCompleted: {
            nEvents += 1
        })

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

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [Subscription(200, 250)])
        XCTAssertTrue(subject.isDisposed)
    }

    func testRefCount_DoesntConnectsOnFirstInCaseSynchronousCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            ])

        let subject = PublishSubject<Int>()
        subject.on(.completed)

        let conn = TestConnectableObservable(o: xs.asObservable(), s: subject)

        let res = scheduler.start { conn.refCount() }

        XCTAssertEqual(res.events, [
            completed(200, Int.self)
            ])

        XCTAssertEqual(xs.subscriptions, [])
    }

    func testRefCount_DoesntConnectsOnFirstInCaseSynchronousError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            ])

        let subject = PublishSubject<Int>()
        subject.on(.error(testError))

        let conn = TestConnectableObservable(o: xs.asObservable(), s: subject)

        let res = scheduler.start { conn.refCount() }

        XCTAssertEqual(res.events, [
            error(200, testError, Int.self)
            ])

        XCTAssertEqual(xs.subscriptions, [])
    }

    func testRefCount_NotConnected() {
        _ = TestScheduler(initialClock: 0)

        var disconnected = false
        var count = 0

        let xs: Observable<Int> = Observable.deferred {
            count += 1
            return Observable.create { obs in
                return Disposables.create {
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
        XCTAssertTrue(disconnected)
    }

    func testRefCount_Error() {
        let xs: Observable<Int> = Observable.error(testError)

        let res = xs.publish().refCount()
        _ = res.subscribe { event in
            switch event {
            case .next:
                XCTAssertTrue(false)
            case .error(let error):
                XCTAssertErrorEqual(error, testError)
            case .completed:
                XCTAssertTrue(false)
            }
        }
        _ = res.subscribe { event in
            switch event {
            case .next:
                XCTAssertTrue(false)
            case .error(let error):
                XCTAssertErrorEqual(error, testError)
            case .completed:
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
        let o1 = scheduler.createObserver(Int.self)
        scheduler.scheduleAt(215) { d1 = res.subscribe(o1) }
        scheduler.scheduleAt(235) { d1.dispose() }

        var d2: Disposable!
        let o2 = scheduler.createObserver(Int.self)
        scheduler.scheduleAt(225) { d2 = res.subscribe(o2) }
        scheduler.scheduleAt(275) { d2.dispose() }

        var d3: Disposable!
        let o3 = scheduler.createObserver(Int.self)
        scheduler.scheduleAt(255) { d3 = res.subscribe(o3) }
        scheduler.scheduleAt(265) { d3.dispose() }

        var d4: Disposable!
        let o4 = scheduler.createObserver(Int.self)
        scheduler.scheduleAt(285) { d4 = res.subscribe(o4) }
        scheduler.scheduleAt(320) { d4.dispose() }

        scheduler.start()

        XCTAssertEqual(o1.events, [
            next(220, 2),
            next(230, 3)
            ])

        XCTAssertEqual(o2.events, [
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            next(270, 7)
            ])

        XCTAssertEqual(o3.events, [
            next(260, 6)
            ])

        XCTAssertEqual(o4.events, [
            next(290, 9),
            completed(300)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(215, 275),
            Subscription(285, 300)
            ])
    }

    func testRefCount_synchronousResubscribingOnErrorWorks() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs1 = scheduler.createColdObservable([
            next(10, 1),
            error(20, testError)
            ])

        let xs2 = scheduler.createColdObservable([
            next(10, 2),
            error(30, testError1)
            ])

        let xs3 = scheduler.createColdObservable([
            next(10, 3),
            error(40, testError2)
            ])

        var attempts = 0

        let xs = Observable.deferred { () -> Observable<Int> in
            defer { attempts += 1 }
            switch attempts {
            case 0: return xs1.asObservable()
            case 1: return xs2.asObservable()
            default: return xs3.asObservable()
            }
        }

        let res = xs.multicast { PublishSubject() }.refCount()

        let o1 = scheduler.createObserver(Int.self)
        let o2 = scheduler.createObserver(Int.self)
        let o3 = scheduler.createObserver(Int.self)
        scheduler.scheduleAt(215) {
            _ = res.subscribe { event in
                o1.on(event)
                switch event {
                case .error:
                    _ = res.subscribe(o1)
                default: break
                }
            }
        }
        scheduler.scheduleAt(220) {
            _ = res.subscribe { event in
                o2.on(event)
                switch event {
                case .error:
                    _ = res.subscribe(o2)
                default: break
                }
            }
        }

        scheduler.scheduleAt(400) {
            _ = res.subscribe(o3)
        }

        scheduler.start()

        XCTAssertEqual(o1.events, [
            next(225, 1),
            error(235, testError),
            next(245, 2),
            error(265, testError1)
            ])

        XCTAssertEqual(o2.events, [
            next(225, 1),
            error(235, testError),
            next(245, 2),
            error(265, testError1)
            ])

        XCTAssertEqual(o3.events, [
            next(410, 3),
            error(440, testError2)
            ])

        XCTAssertEqual(xs1.subscriptions, [
            Subscription(215, 235),
            ])
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(235, 265),
            ])
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(400, 440),
            ])
    }

    func testRefCount_synchronousResubscribingOnCompletedWorks() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs1 = scheduler.createColdObservable([
            next(10, 1),
            completed(20)
            ])

        let xs2 = scheduler.createColdObservable([
            next(10, 2),
            completed(30)
            ])

        let xs3 = scheduler.createColdObservable([
            next(10, 3),
            completed(40)
            ])

        var attempts = 0

        let xs = Observable.deferred { () -> Observable<Int> in
            defer { attempts += 1 }
            switch attempts {
            case 0: return xs1.asObservable()
            case 1: return xs2.asObservable()
            default: return xs3.asObservable()
            }
        }

        let res = xs.multicast { PublishSubject() }.refCount()

        let o1 = scheduler.createObserver(Int.self)
        let o2 = scheduler.createObserver(Int.self)
        let o3 = scheduler.createObserver(Int.self)
        scheduler.scheduleAt(215) {
            _ = res.subscribe { event in
                o1.on(event)
                switch event {
                case .completed:
                    _ = res.subscribe(o1)
                default: break
                }
            }
        }
        scheduler.scheduleAt(220) {
            _ = res.subscribe { event in
                o2.on(event)
                switch event {
                case .completed:
                    _ = res.subscribe(o2)
                default: break
                }
            }
        }

        scheduler.scheduleAt(400) {
            _ = res.subscribe(o3)
        }

        scheduler.start()

        XCTAssertEqual(o1.events, [
            next(225, 1),
            completed(235),
            next(245, 2),
            completed(265)
            ])

        XCTAssertEqual(o2.events, [
            next(225, 1),
            completed(235),
            next(245, 2),
            completed(265)
            ])

        XCTAssertEqual(o3.events, [
            next(410, 3),
            completed(440),
            ])

        XCTAssertEqual(xs1.subscriptions, [
            Subscription(215, 235),
            ])
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(235, 265),
            ])
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(400, 440),
            ])
    }

    #if TRACE_RESOURCES
        func testRefCountReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).publish().refCount().subscribe()
        }

        func testRefCountReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).publish().refCount().subscribe()
        }
    #endif
}

extension ObservableMulticastTest {
    func testReplayCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            error(130, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.debug("1").replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.debug("2").subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 520),
            Subscription(650, 700)
            ])
    }

    func testReplayCount_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            error(90, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            error(490, testError),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 490),
            Subscription(650, 700)
            ])
    }

    func testReplayCount_Complete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(90)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            completed(490),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 490),
            Subscription(650, 700)
            ])
    }

    func testReplayCount_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(130)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(3) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(475) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 520),
            Subscription(650, 700)
            ])
    }

    func testReplayOneCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(130)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 520),
            Subscription(650, 700)
            ])
    }

    func testReplayOneCount_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            error(90, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            error(490, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 490),
            Subscription(650, 700)
            ])
    }

    func testReplayOneCount_Complete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(90)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            completed(490)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 490),
            Subscription(650, 700)
            ])
    }

    func testReplayOneCount_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(90)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replay(1) }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(475) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 490),
            Subscription(650, 700)
            ])
    }

    func testReplayAll_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(130)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replayAll() }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 5),
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 520),
            Subscription(650, 700)
            ])
    }


    func testReplayAll_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            error(90, testError)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replayAll() }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 5),
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            error(490, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 490),
            Subscription(650, 700)
            ])
    }

    func testReplayAll_Complete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(90)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replayAll() }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 5),
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            next(480, 25),
            completed(490)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 490),
            Subscription(650, 700)
            ])
    }

    func testReplayAll_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 5),
            next(20, 9),
            next(30, 11),
            next(40, 20),
            next(50, 22),
            next(60, 23),
            next(70, 24),
            next(80, 25),
            completed(130)
            ])

        var ys: ConnectableObservable<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(Defaults.created) { ys = xs.replayAll() }
        scheduler.scheduleAt(450, action: { subscription = ys.subscribe(res) })
        scheduler.scheduleAt(475) { subscription.dispose() }

        scheduler.scheduleAt(400) { connection = ys.connect() }
        scheduler.scheduleAt(520) { connection.dispose() }

        scheduler.scheduleAt(650) { connection = ys.connect() }
        scheduler.scheduleAt(700) { connection.dispose() }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(450, 5),
            next(450, 9),
            next(450, 11),
            next(450, 20),
            next(450, 22),
            next(460, 23),
            next(470, 24),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(400, 520),
            Subscription(650, 700)
            ])
    }

    #if TRACE_RESOURCES
        func testReplayNReleasesResourcesOnComplete() {
            let replay = Observable<Int>.just(1).replay(1)
            _ = replay.connect()
            _ = replay.subscribe()
        }

        func testReplayNReleasesResourcesOnError() {
            let replay = Observable<Int>.error(testError).replay(1)
            _ = replay.connect()
            _ = replay.subscribe()
        }

        func testReplayAllReleasesResourcesOnComplete() {
            let replay = Observable<Int>.just(1).replayAll()
            _ = replay.connect()
            _ = replay.subscribe()
        }
        
        func testReplayAllReleasesResourcesOnError() {
            let replay = Observable<Int>.error(testError).replayAll()
            _ = replay.connect()
            _ = replay.subscribe()
        }
    #endif
}
