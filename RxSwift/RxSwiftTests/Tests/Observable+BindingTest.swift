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
        
        let conn = ConnectableObservable(o: xs, s: subject)
        
        var res = scheduler.start { conn >- refCount }
        
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
        let scheduler = TestScheduler(initialClock: 0)
        
        var disconnected = false
        var count = 0
        
        let xs: Observable<Int> = defer {
            count++
            return create { obs in
                return success(AnonymousDisposable {
                    disconnected = true
                })
            }
        }
        
        let subject = MySubject<Int>()
        
        let conn = ConnectableObservable(o: xs, s: subject)
        let refd = conn >- refCount
        
        var dis1 = *refd.subscribe(ObserverOf(NopObserver()))
        XCTAssertEqual(1, count)
        XCTAssertEqual(1, subject.subscribeCount)
        XCTAssertFalse(disconnected)
        
        var dis2 = *refd.subscribe(ObserverOf(NopObserver()))
        XCTAssertEqual(1, count)
        XCTAssertEqual(2, subject.subscribeCount)
        XCTAssertFalse(disconnected)
        
        dis1.dispose()
        XCTAssertFalse(disconnected)
        dis2.dispose()
        XCTAssertTrue(disconnected)
        disconnected = false
        
        var dis3 = *refd.subscribe(ObserverOf(NopObserver()))
        XCTAssertEqual(2, count)
        XCTAssertEqual(3, subject.subscribeCount)
        XCTAssertFalse(disconnected)
        
        dis3.dispose()
        XCTAssertTrue(disconnected);
    }
    
    func testRefCount_Error() {
        let xs: Observable<Int> = failWith(testError)
        
        let res = xs >- publish >- refCount
        res >- subscribe { event in
            switch event {
            case .Next:
                XCTAssertTrue(false)
            case .Error(let error):
                XCTAssertEqual(error, testError)
            case .Completed:
                XCTAssertTrue(false)
            }
        }
        res >- subscribe { event in
            switch event {
            case .Next:
                XCTAssertTrue(false)
            case .Error(let error):
                XCTAssertEqual(error, testError)
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
        
        var res = xs >- publish >- refCount
        
        var d1: Disposable!
        var o1: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(215) { d1 = *res.subscribe(ObserverOf(o1)) }
        scheduler.scheduleAt(235) { d1.dispose() }
        
        var d2: Disposable!
        var o2: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(225) { d2 = *res.subscribe(ObserverOf(o2)) }
        scheduler.scheduleAt(275) { d2.dispose() }
        
        var d3: Disposable!
        var o3: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(255) { d3 = *res.subscribe(ObserverOf(o3)) }
        scheduler.scheduleAt(265) { d3.dispose() }
        
        var d4: Disposable!
        var o4: MockObserver<Int> = scheduler.createObserver()
        scheduler.scheduleAt(285) { d4 = *res.subscribe(ObserverOf(o4)) }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(3) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }

        scheduler.scheduleAt(500) { connection = *ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = *ys.connect() }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(3) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(3) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(3) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(475) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = *ys.connect() }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(1) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = *ys.connect() }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(1) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(1) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
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
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(1) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(475) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
        scheduler.scheduleAt(550) { connection.dispose() }
        
        scheduler.scheduleAt(650) { connection = *ys.connect() }
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