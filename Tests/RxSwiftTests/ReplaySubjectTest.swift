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

    func test_noEvents() {
        let scheduler = TestScheduler(initialClock: 0)

        let subject = ReplaySubject<Int>.create(bufferSize: 3)
        let result = scheduler.createObserver(Int.self)

        _ = subject.subscribe(result)

        XCTAssertTrue(result.events.isEmpty)
    }

    func test_fewerEventsThanBufferSize() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subject.onNext(1) }
        scheduler.scheduleAt(200) { subject.onNext(2) }
        scheduler.scheduleAt(300) { subscription = subject.subscribe(result) }
        scheduler.scheduleAt(350) {
            XCTAssertEqual(result.events, [
                .next(300, 1),
                .next(300, 2),
            ])
        }
        scheduler.scheduleAt(400) { subscription.dispose() }

        scheduler.start()
    }

    func test_moreEventsThanBufferSize() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subject.onNext(1) }
        scheduler.scheduleAt(200) { subject.onNext(2) }
        scheduler.scheduleAt(250) { subject.onNext(3) }
        scheduler.scheduleAt(300) { subject.onNext(4) }
        scheduler.scheduleAt(350) { subject.onNext(5) }
        scheduler.scheduleAt(400) { subscription = subject.subscribe(result) }
        scheduler.scheduleAt(450) {
            XCTAssertEqual(result.events, [
                .next(400, 3),
                .next(400, 4),
                .next(400, 5),
            ])
        }
        scheduler.scheduleAt(500) { subscription.dispose() }

        scheduler.start()
    }

    func test_moreEventsThanBufferSizeMultipleObservers() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil
        let result1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let result2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subscription1 = subject.subscribe(result1) }
        scheduler.scheduleAt(200) { subject.onNext(1) }
        scheduler.scheduleAt(250) { subject.onNext(2) }
        scheduler.scheduleAt(300) { subject.onNext(3) }
        scheduler.scheduleAt(350) { subject.onNext(4) }
        scheduler.scheduleAt(400) { subject.onNext(5) }
        scheduler.scheduleAt(450) { subscription2 = subject.subscribe(result2) }
        scheduler.scheduleAt(500) {
            XCTAssertEqual(result1.events, [
                .next(200, 1),
                .next(250, 2),
                .next(300, 3),
                .next(350, 4),
                .next(400, 5),
            ])
            XCTAssertEqual(result2.events, [
                .next(450, 3),
                .next(450, 4),
                .next(450, 5),
            ])
        }
        scheduler.scheduleAt(550) {
            subscription1.dispose()
            subscription2.dispose()
        }

        scheduler.start()
    }

    func test_subscribingBeforeComplete() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subject.onNext(1) }
        scheduler.scheduleAt(200) { subject.onNext(2) }
        scheduler.scheduleAt(250) { subject.onNext(3) }
        scheduler.scheduleAt(300) { subject.onNext(4) }
        scheduler.scheduleAt(350) { subject.onNext(5) }
        scheduler.scheduleAt(400) { subscription = subject.subscribe(result) }
        scheduler.scheduleAt(450) { subject.onCompleted() }
        scheduler.scheduleAt(500) {
            XCTAssertEqual(result.events, [
                .next(400, 3),
                .next(400, 4),
                .next(400, 5),
                .completed(450),
            ])
        }
        scheduler.scheduleAt(550) { subscription.dispose() }

        scheduler.start()
    }

    func test_subscribingAfterComplete() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subject.onNext(1) }
        scheduler.scheduleAt(200) { subject.onNext(2) }
        scheduler.scheduleAt(250) { subject.onNext(3) }
        scheduler.scheduleAt(300) { subject.onNext(4) }
        scheduler.scheduleAt(350) { subject.onNext(5) }
        scheduler.scheduleAt(400) { subject.onCompleted() }
        scheduler.scheduleAt(450) { subscription = subject.subscribe(result) }
        scheduler.scheduleAt(500) {
            XCTAssertEqual(result.events, [
                .next(450, 3),
                .next(450, 4),
                .next(450, 5),
                .completed(450),
            ])
        }
        scheduler.scheduleAt(550) { subscription.dispose() }

        scheduler.start()
    }

    func test_subscribingBeforeError() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subject.onNext(1) }
        scheduler.scheduleAt(200) { subject.onNext(2) }
        scheduler.scheduleAt(250) { subject.onNext(3) }
        scheduler.scheduleAt(300) { subject.onNext(4) }
        scheduler.scheduleAt(350) { subject.onNext(5) }
        scheduler.scheduleAt(400) { subscription = subject.subscribe(result) }
        scheduler.scheduleAt(450) { subject.onError(testError) }
        scheduler.scheduleAt(500) {
            XCTAssertEqual(result.events, [
                .next(400, 3),
                .next(400, 4),
                .next(400, 5),
                .error(450, testError),
            ])
        }
        scheduler.scheduleAt(550) { subscription.dispose() }

        scheduler.start()
    }

    func test_subscribingAfterError() {
        let scheduler = TestScheduler(initialClock: 0)

        var subject: ReplaySubject<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { subject = ReplaySubject.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subject.onNext(1) }
        scheduler.scheduleAt(200) { subject.onNext(2) }
        scheduler.scheduleAt(250) { subject.onNext(3) }
        scheduler.scheduleAt(300) { subject.onNext(4) }
        scheduler.scheduleAt(350) { subject.onNext(5) }
        scheduler.scheduleAt(400) { subject.onError(testError) }
        scheduler.scheduleAt(450) { subscription = subject.subscribe(result) }
        scheduler.scheduleAt(500) {
            XCTAssertEqual(result.events, [
                .next(450, 3),
                .next(450, 4),
                .next(450, 5),
                .error(450, testError),
            ])
        }
        scheduler.scheduleAt(550) { subscription.dispose() }

        scheduler.start()
    }
}
