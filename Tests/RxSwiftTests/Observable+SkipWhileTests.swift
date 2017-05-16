//
//  Observable+SkipWhileTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSkipWhileTest : RxTest {
}

extension ObservableSkipWhileTest {

    func testSkipWhile_Complete_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            completed(330),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            completed(330)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 330)
            ])
        
        XCTAssertEqual(4, invoked)
    }
    
    func testSkipWhile_Complete_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testSkipWhile_Error_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            error(270, testError),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        
        
        XCTAssertEqual(res.events, [
            error(270, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
        
        XCTAssertEqual(2, invoked)
    }
    
    func testSkipWhile_Error_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testSkipWhile_Dispose_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start(disposed: 300) {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testSkipWhile_Dispose_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start(disposed: 470) {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(390, 4),
            next(410, 17),
            next(450, 8)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 470)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testSkipWhile_Zero() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(1, invoked)
    }
    
    func testSkipWhile_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                if invoked == 3 {
                    throw testError
                }
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            error(290, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testSkipWhile_Index() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        let res = scheduler.start() {
            xs.skipWhileWithIndex { x, i in i < 5 }
        }
        
        XCTAssertEqual(res.events, [
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testSkipWhile_Index_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            error(400, testError)
            ])
        
        let res = scheduler.start() {
            xs.skipWhileWithIndex { x, i in i < 5 }
        }
        
        XCTAssertEqual(res.events, [
            next(350, 7),
            next(390, 4),
            error(400, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testSkipWhile_Index_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            completed(400)
            ])
        
        let res = scheduler.start() {
            xs.skipWhileWithIndex { x, i in
                if i < 5 {
                    return true
                }
                throw testError
            }
        }
        
        XCTAssertEqual(res.events, [
            error(350, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
            ])
    }

    #if TRACE_RESOURCES
        func testSkipWhileReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).skipWhile { _ in true }.subscribe()
        }

        func testSkipWhileReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).skipWhile { _ in true }.subscribe()
        }

        func testSkipWhileWithIndexReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).skipWhileWithIndex { _ in true }.subscribe()
        }

        func testSkipWhileWithIndexReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).skipWhileWithIndex { _ in true }.subscribe()
        }
    #endif
}
