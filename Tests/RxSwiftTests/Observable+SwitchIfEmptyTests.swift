//
//  Observable+SwitchIfEmptyTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSwitchIfEmptyTest : RxTest {
}

extension ObservableSwitchIfEmptyTest {
    func testSwitchIfEmpty_SourceNotEmpty_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            next(205, 1),
            completed(210, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            completed(50)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            next(205, 1),
            completed(210)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            ])
    }

    func testSwitchIfEmpty_SourceNotEmptyError_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            next(205, 1),
            error(210, testError)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            completed(50)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            next(205, 1),
            error(210, testError)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            ])
    }

    func testSwitchIfEmpty_SourceEmptyError_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            error(210, testError, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            completed(50)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            ])
    }

    func testSwitchIfEmpty_SourceEmpty_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
                completed(210, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
                next(10, 0),
                next(20, 1),
                next(30, 2),
                next(40, 3),
                completed(50)
            ])
        
        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }
        
        XCTAssertEqual(res.events, [
                next(220, 0),
                next(230, 1),
                next(240, 2),
                next(250, 3),
                completed(260)
            ])
        XCTAssertEqual(source.subscriptions, [
                Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
                Subscription(210, 260)
            ])
    }

    func testSwitchIfEmpty_SourceEmpty_SwitchError() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            completed(210, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            error(50, testError)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            next(220, 0),
            next(230, 1),
            next(240, 2),
            next(250, 3),
            error(260, testError)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            Subscription(210, 260)
            ])
    }

    func testSwitchIfEmpty_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
                next(0, 0)
            ])
        let switchSource = scheduler.createColdObservable([
                next(10, 0),
                next(20, 1),
                next(30, 2),
                next(40, 3),
                completed(50)
            ])
        
        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }
        
        XCTAssertEqual(res.events, [])
        XCTAssertEqual(source.subscriptions, [
                Subscription(200, 1000)
            ])
        XCTAssertEqual(switchSource.subscriptions, [])
    }

    #if TRACE_RESOURCES
        func testSwitchIfEmptyReleasesResourcesOnComplete1() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).ifEmpty(switchTo: Observable.just(1)).subscribe()

            testScheduler.start()
        }
        func testSwitchIfEmptyReleasesResourcesOnComplete2() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.empty().ifEmpty(switchTo: Observable.just(1)).subscribe()

            testScheduler.start()
        }
        func testSwitchIfEmptyReleasesResourcesOnError1() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).ifEmpty(switchTo: Observable.just(1)).subscribe()

            testScheduler.start()
        }

        func testSwitchIfEmptyReleasesResourcesOnError2() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.empty().ifEmpty(switchTo: Observable<Int>.error(testError)).subscribe()

            testScheduler.start()
        }
    #endif
}
