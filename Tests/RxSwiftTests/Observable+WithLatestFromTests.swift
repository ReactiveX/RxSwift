//
//  Observable+WithLatestFromTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableWithLatestFromTest : RxTest {
}

extension ObservableWithLatestFromTest {
    
    func testWithLatestFrom_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            next(410, 7),
            next(420, 8),
            next(470, 9),
            next(550, 10),
            completed(590)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            next(410, "7qux"),
            next(420, "8qux"),
            next(470, "9qux"),
            next(550, "10qux"),
            completed(590)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 590)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 400)
        ])
    }
    
    func testWithLatestFrom_TwoObservablesWithImmediateValues() {
        let xs = BehaviorSubject<Int>(value: 3)
        let ys = BehaviorSubject<Int>(value: 5)
        
        let scheduler = TestScheduler(initialClock: 0)

        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
                .take(1)
        }
        
        XCTAssertEqual(res.events, [
            next(200, "35"),
            completed(200)
        ])
    }
    
    func testWithLatestFrom_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            next(370, "baz"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            completed(390)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 390)
        ])
    }
    
    func testWithLatestFrom_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(245, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            next(370, "baz"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(250, "3bar"),
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            completed(390)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 390)
        ])
    }
    
    func testWithLatestFrom_Error1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            next(410, 7),
            next(420, 8),
            next(470, 9),
            next(550, 10),
            error(590, testError)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            next(410, "7qux"),
            next(420, "8qux"),
            next(470, "9qux"),
            next(550, "10qux"),
            error(590, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 590)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 400)
        ])
    }
    
    func testWithLatestFrom_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            error(370, testError)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            error(370, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 370)
        ])
    }
    
    func testWithLatestFrom_Error3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) {
                (x, y) throws -> String in
                if x == 5 {
                    throw testError
                }
                return "\(x)\(y)"
            }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            error(310, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 310)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 310)
        ])
    }

    func testWithLatestFrom_MakeSureDefaultOverloadTakesSecondSequenceValues() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            next(410, 7),
            next(420, 8),
            next(470, 9),
            next(550, 10),
            completed(590)
            ])

        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
            ])

        let res = scheduler.start {
            xs.withLatestFrom(ys)
        }

        XCTAssertEqual(res.events, [
            next(260, "bar"),
            next(310, "bar"),
            next(340, "foo"),
            next(410, "qux"),
            next(420, "qux"),
            next(470, "qux"),
            next(550, "qux"),
            completed(590)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 590)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 400)
            ])
    }

    #if TRACE_RESOURCES
        func testWithLatestFromReleasesResourcesOnComplete1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delay(20, scheduler: scheduler).withLatestFrom(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testWithLatestFromReleasesResourcesOnComplete2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).withLatestFrom(Observable<Int>.just(1).delay(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testWithLatestFromReleasesResourcesOnError1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(20, scheduler: scheduler).withLatestFrom(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testWithLatestFromReleasesResourcesOnError2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).withLatestFrom(Observable<Int>.never().timeout(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
}
