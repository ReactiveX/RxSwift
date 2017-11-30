//
//  Observable+TimeoutTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableTimeoutTest : RxTest {
}

extension ObservableTimeoutTest {
    func testTimeout_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, 0),
            .completed(300)
            ])
        
        let res = scheduler.start {
            xs.timeout(200, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .completed(300)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }
    
    func testTimeout_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, 0),
            .error(300, testError)
            ])
        
        let res = scheduler.start {
            xs.timeout(200, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .error(300, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }
    
    func testTimeout_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, 0),
            ])
        
        let res = scheduler.start {
            xs.timeout(1000, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testTimeout_Duetime_Simple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            .next(10, 42),
            .next(25, 43),
            .next(40, 44),
            .next(50, 45),
            .completed(60)
            ])
        
        let res = scheduler.start {
            xs.timeout(30, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 42),
            .next(225, 43),
            .next(240, 44),
            .next(250, 45),
            .completed(260)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 260)
            ])
    }
    
    func testTimeout_Duetime_Timeout_Exact() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            .next(10, 42),
            .next(20, 43),
            .next(50, 44),
            .next(60, 45),
            .completed(70)
            ])
        
        let res = scheduler.start {
            xs.timeout(30, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 42),
            .next(220, 43),
            .next(250, 44),
            .next(260, 45),
            .completed(270)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
    }

    func testTimeout_Duetime_Timeout() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .next(10, 42),
            .next(20, 43),
            .next(50, 44),
            .next(60, 45),
            .completed(70)
            ])

        let res = scheduler.start {
            xs.timeout(25, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(210, 42),
            .next(220, 43),
            .error(245, RxError.timeout)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 245)
            ])
    }
    
    func testTimeout_Duetime_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(280, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7),
            .next(420, 8),
            .next(470, 9),
            .completed(600)
            ])
        
        let res = scheduler.start(disposed: 370) {
            xs.timeout(40, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(280, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
            ])
    }
    
    func testTimeout_TimeoutOccurs_1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(70, 1),
            .next(130, 2),
            .next(310, 3),
            .next(400, 4),
            .completed(500)
            ])

        let ys = scheduler.createColdObservable([
            .next(50, -1),
            .next(200, -2),
            .next(310, -3),
            .completed(320)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(350, -1),
            .next(500, -2),
            .next(610, -3),
            .completed(620)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 620)
            ])
    }
    
    func testTimeout_TimeoutOccurs_2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(70, 1),
            .next(130, 2),
            .next(240, 3),
            .next(310, 4),
            .next(430, 5),
            .completed(500)
            ])
        
        let ys = scheduler.createColdObservable([
            .next(50, -1),
            .next(200, -2),
            .next(310, -3),
            .completed(320)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(240, 3),
            .next(310, 4),
            .next(460, -1),
            .next(610, -2),
            .next(720, -3),
            .completed(730)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 410)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(410, 730)
            ])
    }
    
    func testTimeout_TimeoutOccurs_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(70, 1),
            .next(130, 2),
            .next(240, 3),
            .next(310, 4),
            .next(430, 5),
            .completed(500)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(240, 3),
            .next(310, 4)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 410)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(410, 1000)
            ])
    }
    
    func testTimeout_TimeoutOccurs_Completed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            .completed(500)
            ])
        
        let ys = scheduler.createColdObservable([
            .next(100, -1)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(400, -1),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 1000)
            ])
    }

    func testTimeout_TimeoutOccurs_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            .error(500, testError)
            ])

        let ys = scheduler.createColdObservable([
            .next(100, -1)
            ])

        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(400, -1),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 1000)
            ])
    }
    
    func testTimeout_TimeoutOccurs_NextIsError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            .next(500, 42)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            .error(100, testError)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .error(400, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(300, 400)
            ])
    }
    
    func testTimeout_TimeoutNotOccurs_Completed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            .completed(250)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            .next(100, -1)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(ys.subscriptions, [])
    }
    
    func testTimeout_TimeoutNotOccurs_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<Int> = scheduler.createHotObservable([
            .error(250, testError)
            ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([
            .next(100, -1)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .error(250, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(ys.subscriptions, [])
    }
    
    func testTimeout_TimeoutNotOccurs() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(70, 1),
            .next(130, 2),
            .next(240, 3),
            .next(320, 4),
            .next(410, 5),
            .completed(500)
            ])
        
        let ys = scheduler.createColdObservable([
            .next(50, -1),
            .next(200, -2),
            .next(310, -3),
            .completed(320)
            ])
        
        let res = scheduler.start {
            xs.timeout(100, other: ys, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(240, 3),
            .next(320, 4),
            .next(410, 5),
            .completed(500)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 500)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            ])
    }

    #if TRACE_RESOURCES
        func testTimeoutReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).timeout(100, other: Observable.empty(), scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testTimeoutReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).timeout(100, other: Observable.empty(), scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif

}
