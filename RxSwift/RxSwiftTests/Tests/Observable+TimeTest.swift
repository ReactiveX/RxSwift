//
//  Observable+TimeTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class ObservableTimeTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// throttle

extension ObservableTimeTest {
    func test_ThrottleTimeSpan_AllPass() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            completed(400)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllPass_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            error(400, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            error(400, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllDrop() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- throttle(40, scheduler)
        }
        
        let correct = [
            next(400, 7),
            completed(400)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllDrop_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            error(400, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(40, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            error(400, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            completed(300)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            error(300, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            error(300, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleSimple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(250, 3),
            next(280, 4),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            next(230, 1),
            next(270, 3),
            next(300, 4),
            completed(300)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
}