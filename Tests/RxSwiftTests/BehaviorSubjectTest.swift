//
//  BehaviorSubjectTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class BehaviorSubjectTest : RxTest {
    
    func test_Infinite() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(70, 1),
            .next(110, 2),
            .next(220, 3),
            .next(270, 4),
            .next(340, 5),
            .next(410, 6),
            .next(520, 7),
            .next(630, 8),
            .next(710, 9),
            .next(870, 10),
            .next(940, 11),
            .next(1020, 12)
        ])
        
        var subject: BehaviorSubject<Int>! = nil
        var subscription: Disposable! = nil
        
        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil
        
        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil
        
        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil
        
        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(1000) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(400) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(900) { subscription3 = subject.subscribe(results3) }
        
        scheduler.scheduleAt(600) { subscription1.dispose() }
        scheduler.scheduleAt(700) { subscription2.dispose() }
        scheduler.scheduleAt(800) { subscription1.dispose() }
        scheduler.scheduleAt(950) { subscription3.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [
            .next(300, 4),
            .next(340, 5),
            .next(410, 6),
            .next(520, 7)
        ])
        
        XCTAssertEqual(results2.events, [
            .next(400, 5),
            .next(410, 6),
            .next(520, 7),
            .next(630, 8)
        ])
        
        XCTAssertEqual(results3.events, [
            .next(900, 10),
            .next(940, 11)
        ])
    }
    
    func test_Finite() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(70, 1),
            .next(110, 2),
            .next(220, 3),
            .next(270, 4),
            .next(340, 5),
            .next(410, 6),
            .next(520, 7),
            .completed(630),
            .next(640, 9),
            .completed(650),
            .error(660, testError)
        ])
        
        var subject: BehaviorSubject<Int>! = nil
        var subscription: Disposable! = nil
        
        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil
        
        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil
        
        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil
        
        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(1000) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(400) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(900) { subscription3 = subject.subscribe(results3) }
        
        scheduler.scheduleAt(600) { subscription1.dispose() }
        scheduler.scheduleAt(700) { subscription2.dispose() }
        scheduler.scheduleAt(800) { subscription1.dispose() }
        scheduler.scheduleAt(950) { subscription3.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [
            .next(300, 4),
            .next(340, 5),
            .next(410, 6),
            .next(520, 7)
            ])
        
        XCTAssertEqual(results2.events, [
            .next(400, 5),
            .next(410, 6),
            .next(520, 7),
            .completed(630)
            ])
        
        XCTAssertEqual(results3.events, [
            .completed(900)
            ])
    }
    
    func test_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(70, 1),
            .next(110, 2),
            .next(220, 3),
            .next(270, 4),
            .next(340, 5),
            .next(410, 6),
            .next(520, 7),
            .error(630, testError),
            .next(640, 9),
            .completed(650),
            .error(660, testError)
            ])
        
        var subject: BehaviorSubject<Int>! = nil
        var subscription: Disposable! = nil
        
        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil
        
        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil
        
        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil
        
        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(1000) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(400) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(900) { subscription3 = subject.subscribe(results3) }
        
        scheduler.scheduleAt(600) { subscription1.dispose() }
        scheduler.scheduleAt(700) { subscription2.dispose() }
        scheduler.scheduleAt(800) { subscription1.dispose() }
        scheduler.scheduleAt(950) { subscription3.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [
            .next(300, 4),
            .next(340, 5),
            .next(410, 6),
            .next(520, 7)
            ])
        
        XCTAssertEqual(results2.events, [
            .next(400, 5),
            .next(410, 6),
            .next(520, 7),
            .error(630, testError)
            ])
        
        XCTAssertEqual(results3.events, [
            .error(900, testError)
            ])
    }
    
    func test_Canceled() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .completed(630),
            .next(640, 9),
            .completed(650),
            .error(660, testError)
            ])
        
        var subject: BehaviorSubject<Int>! = nil
        var subscription: Disposable! = nil
        
        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil
        
        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil
        
        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil
        
        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(1000) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(400) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(900) { subscription3 = subject.subscribe(results3) }
        
        scheduler.scheduleAt(600) { subscription1.dispose() }
        scheduler.scheduleAt(700) { subscription2.dispose() }
        scheduler.scheduleAt(800) { subscription1.dispose() }
        scheduler.scheduleAt(950) { subscription3.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [
            .next(300, 100),
        ])
        
        XCTAssertEqual(results2.events, [
            .next(400, 100),
            .completed(630)
        ])
        
        XCTAssertEqual(results3.events, [
            .completed(900)
        ])
    }

    func test_hasObserversNoObservers() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: BehaviorSubject<Int>! = nil

        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(250) { XCTAssertFalse(subject.hasObservers) }

        scheduler.start()
    }

    func test_hasObserversOneObserver() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: BehaviorSubject<Int>! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(250) { XCTAssertFalse(subject.hasObservers) }
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(350) { XCTAssertTrue(subject.hasObservers) }
        scheduler.scheduleAt(400) { subscription1.dispose() }
        scheduler.scheduleAt(450) { XCTAssertFalse(subject.hasObservers) }

        scheduler.start()
    }

    func test_hasObserversManyObserver() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: BehaviorSubject<Int>! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil

        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(250) { XCTAssertFalse(subject.hasObservers) }
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(301) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(302) { subscription3 = subject.subscribe(results3) }
        scheduler.scheduleAt(350) { XCTAssertTrue(subject.hasObservers) }
        scheduler.scheduleAt(400) { subscription1.dispose() }
        scheduler.scheduleAt(405) { XCTAssertTrue(subject.hasObservers) }
        scheduler.scheduleAt(410) { subscription2.dispose() }
        scheduler.scheduleAt(415) { XCTAssertTrue(subject.hasObservers) }
        scheduler.scheduleAt(420) { subscription3.dispose() }
        scheduler.scheduleAt(450) { XCTAssertFalse(subject.hasObservers) }

        scheduler.start()
    }
}
