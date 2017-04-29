//
//  Observable+DefaultIfEmpty.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableDefaultIfEmptyTest : RxTest {
}

extension ObservableDefaultIfEmptyTest {
    func testDefaultIfEmpty_Source_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
                completed(201, Int.self)
            ])
        let defaultValue = 1
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [
                next(201, 1),
                completed(201)
            ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 201)
            ])
    }
    
    func testDefaultIfEmpty_Source_Errors() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
                error(201, testError, Int.self)
            ])
        let defaultValue = 1
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [
            error(201, testError)
            ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 201)
            ])
    }
    
    func testDefaultIfEmpty_Source_Emits() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
                next(201, 1),
                next(202, 2),
                next(203, 3),
                completed(204)
            ])
        let defaultValue = 42
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [
            next(201, 1),
            next(202, 2),
            next(203, 3),
            completed(204)
            ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 204)
            ])
    }
    
    func testDefaultIfEmpty_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(0, 0)
            ])
        let defaultValue = 42
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    #if TRACE_RESOURCES
        func testDefaultIfEmptyReleasesResourcesOnComplete1() {
            _ = Observable<Int>.just(1).ifEmpty(default: -1).subscribe()
        }

        func testDefaultIfEmptyReleasesResourcesOnComplete2() {
            _ = Observable<Int>.empty().ifEmpty(default: -1).subscribe()
        }

        func testDefaultIfEmptyReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).ifEmpty(default: -1).subscribe()
        }
    #endif
}
