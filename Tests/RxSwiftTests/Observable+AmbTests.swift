//
//  Observable+AmbTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableAmbTest : RxTest {
}

extension ObservableAmbTest {
    
    func testAmb_Never2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testAmb_Never3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1)
            ])
        
        let x3 = scheduler.createHotObservable([
            .next(150, 1)
            ])
        
        let res = scheduler.start {
            Observable.amb([x1, x2, x3].map { $0.asObservable() })
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(x3.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testAmb_Never_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(225)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            .completed(225)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testAmb_RegularShouldDisposeLoser() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(240)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 3),
            .completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .completed(240)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 240)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testAmb_WinnerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .error(220, testError)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 3),
            .completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 2),
            .error(220, testError)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 220)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testAmb_LoserThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .error(230, testError)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 3),
            .completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            .next(210, 3),
            .completed(250)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testAmb_ThrowsBeforeElectionLeft() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1),
            .error(210, testError)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 3),
            .completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            .error(210, testError)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testAmb_ThrowsBeforeElectionRight() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 3),
            .completed(250)
            ])
        
        let x2 = scheduler.createHotObservable([
            .next(150, 1),
            .error(210, testError)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            .error(210, testError)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }

    #if TRACE_RESOURCES
        func testAmb1ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).delay(.seconds(10), scheduler: scheduler).amb(Observable.just(1)).subscribe()
            scheduler.start()
        }

        func testAmb2ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).amb(Observable.just(1).delay(.seconds(10), scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testAmb1ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(.seconds(20), scheduler: scheduler).amb(Observable<Int>.never()).subscribe()
            scheduler.start()
        }

        func testAmb2ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().amb(Observable<Int>.never().timeout(.seconds(20), scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
}

