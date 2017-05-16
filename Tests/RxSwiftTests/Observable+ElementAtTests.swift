//
//  Observable+ElementAtTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableElementAtTest : RxTest {
}

extension ObservableElementAtTest {
    
    func testElementAt_Complete_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            next(460, 72),
            completed(460)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 460)
            ])
    }
    
    
    func testElementAt_Complete_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            completed(320)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            error(320, RxError.argumentOutOfRange)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testElementAt_Error_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            next(460, 72),
            completed(460)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 460)
            ])
    }
    
    func testElementAt_Error_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            error(310, testError)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            error(310, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 310)
            ])
    }
    
    func testElementAt_Dispose_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start(disposed: 250) {
            xs.elementAt(3)
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testElementAt_Dispose_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start(disposed: 400) {
            xs.elementAt(3)
        }
        
        XCTAssertEqual(res.events, [
            next(280, 1),
            completed(280)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 280)
            ])
    }
    
    func testElementAt_First() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.elementAt(0)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            completed(210)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    #if TRACE_RESOURCES
        func testElementAtReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).elementAt(0).subscribe()
        }

        func testElementAtReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).elementAt(1).subscribe()
        }
    #endif
}
