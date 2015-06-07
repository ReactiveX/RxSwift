//
//  Observable+StandardSequenceOperatorsTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift


class ObservableStandardSequenceOperators : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

func isPrime(i: Int) -> Bool {
    if i <= 1 {
        return false
    }
    
    var max = Int(sqrt(Float(i)))
    for (var j = 2; j <= max; ++j) {
        if i % j == 0 {
            return false
        }
    }
    
    return true
}

// where

extension ObservableStandardSequenceOperators  {
    func test_whereComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600),
            next(610, 12),
            error(620, testError),
            completed(630)
        ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs >- filter { (num: Int) -> Bool in
                invoked++;
                return isPrime(num);
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(230, 3),
            next(340, 5),
            next(390, 7),
            next(580, 11),
            completed(600)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
        ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_whereTrue() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs >- filter { (num: Int) -> Bool in
                invoked++
                return true
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(9, invoked)
    }
   
    func test_whereFalse() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs >- filter { (num: Int) -> Bool in
                invoked++
                return false
            }
        }
        
        XCTAssertEqual(res.messages, [
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_whereDisposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start(400) { () -> Observable<Int> in
            return xs >- filter { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(230, 3),
            next(340, 5),
            next(390, 7)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(5, invoked)
    }
}

// takeWhile
extension ObservableStandardSequenceOperators {
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
            return xs >- takeWhile { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
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
            return xs >- takeWhile { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
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
            return xs >- takeWhile { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
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
            return xs >- takeWhile { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
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
        
        let res = scheduler.start(300) { () -> Observable<Int> in
            return xs >- takeWhile { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
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
        
        let res = scheduler.start(400) { () -> Observable<Int> in
            return xs >- takeWhile { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
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
        
        let res = scheduler.start(300) { () -> Observable<Int> in
            return xs >- takeWhile { (num: Int) -> Bool in
                invoked++;
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.messages, [
            completed(205)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 205)
            ])
        
        XCTAssertEqual(1, invoked)
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
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs >- takeWhile { (num: Int, index) -> Bool in
                return index < 5
            }
        }
        
        XCTAssertEqual(res.messages, [
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
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs >- takeWhile { (num: Int, index) -> Bool in
                return index >= 0
            }
        }
        
        XCTAssertEqual(res.messages, [
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
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs >- takeWhile { (num: Int, index) -> Bool in
                return index >= 0
            }
        }
        
        XCTAssertEqual(res.messages, [
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
}