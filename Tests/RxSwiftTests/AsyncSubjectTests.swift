//
//  AsyncSubjectTests.swift
//  Tests
//
//  Created by Victor Galán on 07/01/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest

class AsyncSubjectTests: RxTest {

    func test_hasObserversManyObserver() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: AsyncSubject<Int>! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil

        scheduler.scheduleAt(100) { subject = AsyncSubject() }
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

    func test_shouldNotSendEventsBeforeCompletes() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(110, 2),
            next(220, 3),
            next(270, 4),
            next(340, 5),
            next(410, 6),
            next(520, 7),
            next(630, 8),
            next(710, 9),
            next(870, 10),
            next(940, 11),
            next(1020, 12),
            ])

        var subject: AsyncSubject<Int>! = nil
        var subscription: Disposable! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil

        scheduler.scheduleAt(100) { subject = AsyncSubject<Int>() }
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

        XCTAssertEqual(results1.events, [])

        XCTAssertEqual(results2.events, [])

        XCTAssertEqual(results3.events, [])
    }

    func test_shouldSendLastValueAndCompletedEventWhenCompletes() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(110, 2),
            next(220, 3),
            next(270, 4),
            next(340, 5),
            next(410, 6),
            next(520, 7),
            next(630, 8),
            next(710, 9),
            next(870, 10),
            completed(900),
            next(970, 12),
            next(1000, 13),
            next(1050, 14),
            completed(1100)
            ])

        var subject: AsyncSubject<Int>! = nil
        var subscription: Disposable! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil

        scheduler.scheduleAt(100) { subject = AsyncSubject<Int>() }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(1000) { subscription.dispose() }

        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(400) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(800) { subscription3 = subject.subscribe(results3) }

        scheduler.scheduleAt(1110) { subscription1.dispose() }
        scheduler.scheduleAt(1120) { subscription2.dispose() }
        scheduler.scheduleAt(1140) { subscription3.dispose() }

        scheduler.start()

        XCTAssertEqual(results1.events, [next(900, 10), completed(900)])

        XCTAssertEqual(results2.events, [next(900, 10), completed(900)])

        XCTAssertEqual(results3.events, [next(900, 10), completed(900)])
    }

    func test_shouldIgnoreValuesAfterError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(110, 2),
            next(220, 3),
            next(270, 4),
            next(340, 5),
            next(410, 6),
            next(520, 7),
            next(630, 8),
            next(710, 9),
            next(870, 10),
            error(900, testError),
            next(970, 10),
            next(1000, 10),
            next(1050, 10),
            completed(1100)
            ])

        var subject: AsyncSubject<Int>! = nil
        var subscription: Disposable! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil

        scheduler.scheduleAt(100) { subject = AsyncSubject<Int>() }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(1200) { subscription.dispose() }

        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(400) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(800) { subscription3 = subject.subscribe(results3) }
        
        scheduler.scheduleAt(1110) { subscription1.dispose() }
        scheduler.scheduleAt(1120) { subscription2.dispose() }
        scheduler.scheduleAt(1130) { subscription3.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [error(900, testError)])
        
        XCTAssertEqual(results2.events, [error(900, testError)])
        
        XCTAssertEqual(results3.events, [error(900, testError)])
    }
    
    func test_shouldSendLastValueAndCompletedUponSubscriptionAfterItIsCompleted() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(110, 2),
            next(220, 3),
            next(270, 4),
            next(340, 5),
            next(410, 6),
            next(520, 7),
            next(630, 8),
            next(710, 9),
            next(870, 10),
            completed(900)
            ])
        
        var subject: AsyncSubject<Int>! = nil
        var subscription: Disposable! = nil
        
        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil
        
        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil
        
        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil
        
        scheduler.scheduleAt(100) { subject = AsyncSubject<Int>() }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(1200) { subscription.dispose() } 
        
        scheduler.scheduleAt(1000) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(1200) { subscription2 = subject.subscribe(results2) }
        scheduler.scheduleAt(1400) { subscription3 = subject.subscribe(results3) }
        
        scheduler.scheduleAt(1410) { subscription1.dispose() }
        scheduler.scheduleAt(1420) { subscription2.dispose() }
        scheduler.scheduleAt(1430) { subscription3.dispose() }
        
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [next(1000, 10), completed(1000)])
        
        XCTAssertEqual(results2.events, [next(1200, 10), completed(1200)])
        
        XCTAssertEqual(results3.events, [next(1400, 10), completed(1400)])
    }
}

