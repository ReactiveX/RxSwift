//
//  Observable+TakeWhileTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableTakeWhileTest : RxTest {
}

extension ObservableTakeWhileTest {
    func testTakeWhile_Complete_Before() {
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
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            completed(330)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 330)
        ])
        
        XCTAssertEqual(4, invoked)
    }
    
    func testTakeWhile_Complete_After() {
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
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Error_Before() {
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
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            error(270, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
        
        XCTAssertEqual(2, invoked)
    }
    
    func testTakeWhile_Error_After() {
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
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Dispose_Before() {
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
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start(disposed: 300) { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testTakeWhile_Dispose_After() {
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
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start(disposed: 400) { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Zero() {
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
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start(disposed: 300) { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            completed(205)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 205)
            ])
        
        XCTAssertEqual(1, invoked)
    }
    
    func testTakeWhile_Throw() {
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
        
        let res = scheduler.start() { () -> Observable<Int> in
            return xs.takeWhile { num in
                invoked += 1
                
                if invoked == 3 {
                    throw testError
                }
                
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            error(290, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testTakeWhile_Index1() {
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
            error(600, testError),
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num, index in index < 5 }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            completed(350)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
        ])
    }
    
    func testTakeWhile_Index2() {
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
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num , index  in return index >= 0 }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            completed(400)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testTakeWhile_Index_Error() {
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
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num, index in index >= 0 }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            error(400, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    
    func testTakeWhile_Index_SelectorThrows() {
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
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num, index in
                if index < 5 {
                    return true
                }
                
                throw testError
            }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            error(350, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
            ])
    }

    #if TRACE_RESOURCES
        func testTakeWhileReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).takeWhile { _ in true }.subscribe()
        }

        func testTakeWhile1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).takeWhile { _ in true }.subscribe()
        }

        func testTakeWhile2ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).takeWhile { _ -> Bool in throw testError }.subscribe()
        }

        func testTakeWhileWithIndexReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).takeWhileWithIndex { _ in true }.subscribe()
        }

        func testTakeWhileWithIndex1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).takeWhileWithIndex { _ in true }.subscribe()
        }

        func testTakeWhileWithIndex2ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).takeWhileWithIndex { _ -> Bool in throw testError }.subscribe()
        }
    #endif
}
