//
//  Observable+ConcurrencyTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 5/2/15.
//
//

import Foundation
import XCTest
import RxSwift

class ObservableConcurrencyTest : RxTest {
    
}

// observeSingleOn
extension ObservableConcurrencyTest {
    func testObserveSingleOn_DeadlockSimple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var nEvents = 0
        
        let observable = returnElement(0) >- observeSingleOn(scheduler)
        let _d = observable >- subscribeNext { n in
            nEvents++
        } >- scopedDispose

        scheduler.start()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveSingleOn_DeadlockErrorImmediatelly() {
        let scheduler = TestScheduler(initialClock: 0)

        var nEvents = 0
        
        let observable: Observable<Int> = failWith(testError) >- observeSingleOn(scheduler)
        let _d = observable >- subscribeError { n in
            nEvents++
        } >- scopedDispose
        
        scheduler.start()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveSingleOn_DeadlockEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var nEvents = 0
        
        let observable: Observable<Int> = empty() >- observeSingleOn(scheduler)
        let _d = observable >- subscribeCompleted {
            nEvents++
        } >- scopedDispose

        scheduler.start()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveSingleOn_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Simple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
            next(300, 0),
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(300, testError)
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
            error(300, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(290, 0),
            error(300, testError)
            ])
        
        let res = scheduler.start(290) { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 290)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}