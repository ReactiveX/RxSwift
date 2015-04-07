//
//  Observable+SingleTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import Rx

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

// map
// these test are not port from Rx
extension ObservableSingleTest {
    func testMap_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs >- map { $0 * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- map { $0 * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- map { $0 * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            error(300, testError)
            ])
        
        let res = scheduler.start { xs >- map { $0 * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
            error(300, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            error(300, testError)
            ])
        
        let res = scheduler.start(290) { xs >- map { $0 * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
        ]
        
        let correctSubscriptions = [
            Subscription(200, 290)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            error(300, testError)
            ])
        
        let res = scheduler.start { xs >- mapOrDie { $0 < 2 ? success($0 * 2) : .Error(testError) } }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            error(230, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 230)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs >- mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 5),
            next(220, 6),
            next(230, 7),
            next(240, 8),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            next(230, (7 + 2) * 2),
            next(240, (8 + 3) * 2),
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 5),
            next(220, 6),
            next(230, 7),
            next(240, 8),
            error(300, testError)
            ])
        
        let res = scheduler.start { xs >- mapWithIndex { ($0 + $1) * 2 }  }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            next(230, (7 + 2) * 2),
            next(240, (8 + 3) * 2),
            error(300, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 5),
            next(220, 6),
            next(230, 7),
            next(240, 8),
            error(300, testError)
            ])
        
        let res = scheduler.start(290) { xs >- mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            next(230, (7 + 2) * 2),
            next(240, (8 + 3) * 2),
        ]
        
        let correctSubscriptions = [
            Subscription(200, 290)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 5),
            next(220, 6),
            next(230, 7),
            next(240, 8),
            error(300, testError)
            ])
        
        let res = scheduler.start { xs >- mapWithIndexOrDie { $0 < 7 ? success(($0 + $1) * 2) : .Error(testError) } }
        
        let correctMessages: [Recorded<Int>] = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            error(230, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 230)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}