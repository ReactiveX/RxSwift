//
//  ReplaySubjectTest.swift
//  Tests
//
//  Created by Ryszkiewicz Peter, US-204 on 5/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ReplaySubjectTest: RxTest {

    func test_hasObserversNoObservers() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 1) }
        scheduler.scheduleAt(250) { XCTAssertFalse(subject.hasObservers) }

        scheduler.start()
    }

    func test_hasObserversOneObserver() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 1) }
        scheduler.scheduleAt(250) { XCTAssertFalse(subject.hasObservers) }
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        scheduler.scheduleAt(350) { XCTAssertTrue(subject.hasObservers) }
        scheduler.scheduleAt(400) { subscription1.dispose() }
        scheduler.scheduleAt(450) { XCTAssertFalse(subject.hasObservers) }

        scheduler.start()
    }

    func test_hasObserversManyObserver() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil

        let results1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let results2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        let results3 = scheduler.createObserver(Int.self)
        var subscription3: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 1) }
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
