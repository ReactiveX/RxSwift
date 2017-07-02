//
//  Completable+AndThen.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/2/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class CompletableAndThenTest : RxTest {
}

extension CompletableAndThenTest {

    func testCompletableCompleted_CompletableCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Never> = scheduler.createHotObservable([
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asCompletable()).asObservable()
        }

        XCTAssertEqual(res.events, [
            completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    func testCompletableError_CompletableCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            error(210, testError),
            ])

        let x2: TestableObservable<Never> = scheduler.createHotObservable([
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asCompletable()).asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_CompletableError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Never> = scheduler.createHotObservable([
            error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asCompletable()).asObservable()
        }

        XCTAssertEqual(res.events, [
            error(290, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }
}

extension CompletableAndThenTest {

    func testCompletableCompleted_SingleNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            next(290, 1),
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asSingle()).asObservable()
        }

        XCTAssertEqual(res.events, [
            next(290, 1),
            completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }


    func testCompletableError_SingleNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            error(210, testError),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            next(290, 1),
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asSingle()).asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_SingleError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asSingle()).asObservable()
        }

        XCTAssertEqual(res.events, [
            error(290, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }
}

extension CompletableAndThenTest {

    func testCompletableCompleted_MaybeNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            next(290, 1),
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe()).asObservable()
        }

        XCTAssertEqual(res.events, [
            next(290, 1),
            completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }


    func testCompletableError_MaybeNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            error(210, testError),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            next(290, 1),
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe()).asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_MaybeError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe()).asObservable()
        }

        XCTAssertEqual(res.events, [
            error(290, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    func testCompletableCompleted_MaybeEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            completed(290)
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe()).asObservable()
        }

        XCTAssertEqual(res.events, [
            completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }
}

extension CompletableAndThenTest {

    func testCompletableCompleted_ObservableNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            next(280, 1),
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            next(280, 1),
            completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }


    func testCompletableError_ObservableNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            error(210, testError),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            next(280, 1),
            completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            error(210, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_ObservableError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            error(290, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    func testCompletableCompleted_ObservableEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            completed(290)
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }
}
