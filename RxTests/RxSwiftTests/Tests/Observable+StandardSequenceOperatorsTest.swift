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
        
        var xs = scheduler.createHotObservable([
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
        
        var xs = scheduler.createHotObservable([
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
        
        var xs = scheduler.createHotObservable([
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
        
        var xs = scheduler.createHotObservable([
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
