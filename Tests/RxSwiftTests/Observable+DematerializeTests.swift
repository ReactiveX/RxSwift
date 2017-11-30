//
//  Observable+DematerializeTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableDematerializeTest : RxTest {
}

extension ObservableDematerializeTest {
    func testDematerialize_Range1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Event.next(41)),
            next(210, Event.next(42)),
            next(220, Event.next(43)),
            completed(250),
            completed(251),
        ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        
        XCTAssertEqual(res.events, [
                next(210, 42),
                next(220, 43),
                completed(250)
                ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
        
    }
    
    func testDematerialize_Range2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Event.next(41)),
            next(210, Event.next(42)),
            next(220, Event.next(43)),
            next(230, Event.completed),
            next(231, Event.completed),
            ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            completed(230)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
        
    }
    
    func testDematerialize_Error() {
        let scheduler = TestScheduler(initialClock: 0)
    
        
        let xs = scheduler.createHotObservable([
                next(150, Event.next(41)),
                next(210, Event.next(42)),
                next(220, Event.next(43)),
                error(230, TestError.dummyError),
                error(231, TestError.dummyError),
            ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            error(230, TestError.dummyError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
    
    func testDematerialize_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        
        let xs = scheduler.createHotObservable([
            next(150, Event.next(41)),
            next(210, Event.next(42)),
            next(220, Event.next(43)),
            next(230, Event.error(TestError.dummyError)),
            next(231, Event.error(TestError.dummyError))
            ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            error(230, TestError.dummyError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
    
    func testMaterialize_Dematerialize_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = Observable<Int>.never()
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [])
    }
    
    func testMaterialize_Dematerialize_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testMaterialize_Dematerialize_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testMaterialize_Dematerialize_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        let dummyError = TestError.dummyError
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(250, dummyError)
        ])
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            error(250, dummyError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    #if TRACE_RESOURCES
        func testDematerializeReleasesResourcesOnComplete1() {
            _ = Observable.just(Event.next(1)).dematerialize().subscribe()
        }
        
        func testDematerializeReleasesResourcesOnComplete2() {
            _ = Observable<Event<Int>>.empty().dematerialize().subscribe()
        }
        
        func testDematerializeReleasesResourcesOnError() {
            _ = Observable<Event<Int>>.error(testError).dematerialize().subscribe()
        }
    #endif
}

