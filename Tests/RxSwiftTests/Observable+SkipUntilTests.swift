//
//  Observable+SkipUntilTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSkipUntilTest : RxTest {
}

extension ObservableSkipUntilTest {
    func testSkipUntil_SomeData_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4), //!
            .next(240, 5), //!
            .completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .next(225, 99),
            .completed(230)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
    
        XCTAssertEqual(res.events, [
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_SomeData_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .error(225, testError)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
    
        XCTAssertEqual(res.events, [
            .error(225, testError),
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Error_SomeData() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .error(220, testError)
 
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .next(230, 2),
            .completed(250)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            .error(220, testError),
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 220)
        ])
    }
    
    func testSkipUntil_SomeData_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .completed(225)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Never_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1)
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .next(225, 2), //!
            .completed(250)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Never_Error1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1)
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .error(225, testError)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            .error(225, testError)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_SomeData_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .error(300, testError)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 250)
        ])
    }
    
    func testSkipUntil_SomeData_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 250)
        ])
    }
    
    func testSkipUntil_Never_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
            .completed(225)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
        ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Never_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
        ])
        
        let r = scheduler.createHotObservable([
            .next(150, 1),
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 1000)
        ])
    }
    
    func testSkipUntil_HasCompletedCausesDisposal() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var isDisposed = false
        
        let l = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        ])
        
        let r: Observable<Int> = Observable.create { o in
            return Disposables.create {
                isDisposed = true
            }
        }
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssert(isDisposed, "isDisposed")
    }

    #if TRACE_RESOURCES
        func testSkipUntilReleasesResourcesOnComplete1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delay(20, scheduler: scheduler).skipUntil(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testSkipUntilReleasesResourcesOnComplete2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).skipUntil(Observable<Int>.just(1).delay(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testSkipUntilReleasesResourcesOnError1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(20, scheduler: scheduler).skipUntil(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testSkipUntilReleasesResourcesOnError2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).skipUntil(Observable<Int>.never().timeout(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
}

