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

// simple replay one tests
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