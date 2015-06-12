//
//  Observable+SingleTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class ObservableSingleTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// Creation
extension ObservableSingleTest {
    func testAsObservable_asObservable() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(250)
        ])
        
        let ys = asObservable(xs)
        
        XCTAssert(xs !== ys)
        
        let res = scheduler.start { ys }
     
        let correct = [
            next(220, 2),
            completed(250)
        ]
 
        XCTAssertEqual(res.messages, correct)
    }
    
    
    func testAsObservable_hides() {
        let xs : Observable<Int> = empty()
        
        let res = asObservable(xs)
        
        XCTAssertTrue(res !== xs)
    }
    
    func testAsObservable_never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs : Observable<Int> = never()
        
        let res = scheduler.start { xs }
     
        let correct: [Recorded<Int>] = []
        
        XCTAssertEqual(res.messages, correct)
    }
    
    // ...
}

// Distinct
extension ObservableSingleTest {
    func testDistinctUntilChanged_allChanges() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let res = scheduler.start { xs >- distinctUntilChanged { $0 } }

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDistinctUntilChanged_someChanges() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2), // *
            next(215, 3), // *
            next(220, 3),
            next(225, 2), // *
            next(230, 2),
            next(230, 1), // *
            next(240, 2), // *
            completed(250)
            ])


        let res = scheduler.start { xs >- distinctUntilChanged { $0 } }
        
        let correctMessages = [
            next(210, 2),
            next(215, 3),
            next(225, 2),
            next(230, 1),
            next(240, 2),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDistinctUntilChanged_allEqual() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let res = scheduler.start { xs >- distinctUntilChanged { l, r in true } }
        
        let correctMessages = [
            next(210, 2),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    // ...
}

// Do 
extension ObservableSingleTest {
    func testDo_shouldSeeAllValues() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
    
        var i = 0
        var sum = 2 + 3 + 4 + 5
        let res = scheduler.start { xs >- `do` { e in
                switch e {
                case .Next(let value):
                    i++
                    sum -= e.value ?? 0
                    
                default: break
                }
            }
        }
        
        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)
        
        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDo_plainAction() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        var i = 0
        let res = scheduler.start { xs >- `do` { e in
            switch e {
            case .Next(let value):
                i++
            default: break
            }
            }
        }
        
        XCTAssertEqual(i, 4)
        
        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDo_nextCompleted() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        var i = 0
        var sum = 2 + 3 + 4 + 5
        var completedEvaluation = false
        let res = scheduler.start { xs >- `do` { e in
            switch e {
            case .Next(let value):
                i++
                sum -= value.value
            case .Completed:
                completedEvaluation = true
            default: break
            }
            }
        }
        
        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)
        XCTAssertEqual(completedEvaluation, true)
        
        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDo_completedNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let recordedEvents: [Recorded<Int>] = [
        ]
        
        let xs = scheduler.createHotObservable(recordedEvents)
        
        var i = 0
        var completedEvaluation = false
        let res = scheduler.start { xs >- `do` { e in
            switch e {
            case .Next(let value):
                i++
            case .Completed:
                completedEvaluation = true
            default: break
            }
            }
        }
        
        XCTAssertEqual(i, 0)
        XCTAssertEqual(completedEvaluation, false)
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDo_nextError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            error(250, testError)
            ])
        
        var i = 0
        var sum = 2 + 3 + 4 + 5
        var sawError = false
        let res = scheduler.start { xs >- `do` { e in
            switch e {
            case .Next(let value):
                i++
                sum -= value.value
            case .Error:
                sawError = true
            default: break
            }
            }
        }
        
        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)
        XCTAssertEqual(sawError, true)
        
        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            error(250, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDo_nextErrorNot() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        var i = 0
        var sum = 2 + 3 + 4 + 5
        var sawError = false
        let res = scheduler.start { xs >- `do` { e in
            switch e {
            case .Next(let value):
                i++
                sum -= value.value
            case .Error:
                sawError = true
            default: break
            }
            }
        }
        
        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)
        XCTAssertEqual(sawError, false)
        
        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    // ...
}

