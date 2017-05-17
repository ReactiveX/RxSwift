//
//  Observable+RepeatWhenTests.swift
//  Tests
//
//  Created by sergdort on 16/05/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableRepeatWhenTests: RxTest {
    
    func testRepeatWhen_never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
        ])
        
        let ys = scheduler.createColdObservable([
            completed(1, Int.self)
        ])
        
        let results = scheduler.start {
            return xs.repeatWhen { _ in
                return ys
            }
        }
        
        XCTAssertEqual(results.events, [
            completed(250)
        ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 201)
        ])
    }
    
    func testRepeatWhen_Observable_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let ys: TestableObservable<Int> = scheduler.createColdObservable([])
        
        let results = scheduler.start {
            return xs.repeatWhen { _ in
                return ys
            }
        }
        
        XCTAssertEqual(results.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 1000)
        ])
    }
    
    func testRepeatObservable_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            completed(250)
            ])
        
        let ys = scheduler.createColdObservable([
            completed(1, Int.self)
        ])
        
        let results = scheduler.start {
            return xs.repeatWhen { _ in
                return ys
            }
        }
        
        XCTAssertEqual(results.events, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450)
        ])
    }
    
    func testRepeatWhenObservable_NextError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, testError),
            completed(40)
        ])
        
        let results = scheduler.start {
            return xs.repeatWhen { notifications in
                return notifications.scan(0, accumulator: { (count, _) in
                    if count == 2 {
                        throw testError
                    }
                    return count + 1
                })
            }
        }
        
        XCTAssertEqual(results.events, [
            next(210, 1),
            next(220, 2),
            error(230, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
        ])
    }
    
    func testRepeatWhenObservable_Complete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            completed(30)
        ])
        
        let ys = scheduler.createColdObservable([
            completed(0, Int.self)
        ])
        
        let results = scheduler.start {
            return xs.repeatWhen { _ in
                return ys
            }
        }

        XCTAssertEqual(results.events, [
            next(210, 1),
            next(220, 2),
            completed(230)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 200)
        ])
    }
    
    func testRepeatWhenNextComplete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 1),
                next(20, 2),
                completed(30)
        ])

        let results = scheduler.start {
            return xs.repeatWhen { notifications in
                return notifications.scan(0) { (count, _) in
                    return count + 1
                }.takeWhile { count in
                    return count < 2
                }
            }
        }

        XCTAssertEqual(results.events, [
            next(210, 1),
                next(220, 2),
                next(240, 1),
                next(250, 2),
                completed(260)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230),
            Subscription(230, 260)
        ])
    }
    
    func testRepeatWhenInfinite() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 1),
                next(20, 2),
                completed(30)
        ])

        let ys: TestableObservable<Int> = scheduler.createColdObservable([])

        let results = scheduler.start {
            return xs.repeatWhen { _ in
                return ys
            }
        }

        XCTAssertEqual(results.events, [
            next(210, 1),
                next(220, 2)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
        ])
    }
}
