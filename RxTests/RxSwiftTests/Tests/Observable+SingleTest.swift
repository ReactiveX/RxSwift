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
// this is now part of interface 
/*
extension ObservableSingleTest {
    func testAsObservable_asObservable() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(250)
        ])
        
        let ys = xs.asObservable()
        
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
        
        let res = xs.asObservable()
        
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
*/

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
        
        let res = scheduler.start { xs.distinctUntilChanged { $0 } }

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


        let res = scheduler.start { xs.distinctUntilChanged { $0 } }
        
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
        
        let res = scheduler.start { xs.distinctUntilChanged { l, r in true } }
        
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
    
    func testDistinctUntilChanged_allDifferent() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 2),
            next(230, 2),
            next(240, 2),
            completed(250)
            ])
        
        let res = scheduler.start { xs.distinctUntilChanged({ l, r in false }) }
        
        let correctMessages = [
            next(210, 2),
            next(220, 2),
            next(230, 2),
            next(240, 2),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDistinctUntilChanged_keySelector_Div2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 4),
            next(230, 3),
            next(240, 5),
            completed(250)
            ])
        
        let res = scheduler.start { xs.distinctUntilChanged({ $0 % 2 }) }
        
        let correctMessages = [
            next(210, 2),
            next(230, 3),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDistinctUntilChanged_keySelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250)
            ])
        
        let res = scheduler.start { xs.distinctUntilChanged({ _ in throw testError }) }
        
        let correctMessages = [
            next(210, 2),
            error(220, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 220)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDistinctUntilChanged_comparerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250)
            ])
        
        let res = scheduler.start { xs.distinctUntilChanged({ $0 }, comparer: { _, _ in throw testError }) }
        
        let correctMessages = [
            next(210, 2),
            error(220, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 220)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
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
        let res = scheduler.start { xs.doOn { e in
                switch e {
                case .Next:
                    i++
                    sum -= e.element ?? 0
                    
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
        let res = scheduler.start { xs.doOn { e in
            switch e {
            case .Next(_):
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
        let res = scheduler.start { xs.doOn { e in
            switch e {
            case .Next(let value):
                i++
                sum -= value
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
        let res = scheduler.start { xs.doOn { e in
            switch e {
            case .Next(_):
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
        let res = scheduler.start { xs.doOn { e in
            switch e {
            case .Next(let value):
                i++
                sum -= value
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
        let res = scheduler.start { xs.doOn { e in
            switch e {
            case .Next(let value):
                i++
                sum -= value
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
    
    func testDo_Throws() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(250)
            ])
        
        let res = scheduler.start { xs.doOn { _ in
                throw testError
            }
        }
        
        let correctMessages = [
            error(210, testError) as Recorded<Int>
        ]
        
        let correctSubscriptions = [
            Subscription(200, 210)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}

// retry
extension ObservableSingleTest {
    func testRetry_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.retry()
        }
        
        XCTAssertEqual(res.messages, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450)
            ])
    }

    func testRetry_Infinite() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            ])
        
        let res = scheduler.start {
            xs.retry()
        }
        
        XCTAssertEqual(res.messages, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testRetry_Observable_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            error(250, testError),
            ])
        
        let res = scheduler.start(1100) {
            xs.retry()
        }
        
        XCTAssertEqual(res.messages, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            next(550, 1),
            next(600, 2),
            next(650, 3),
            next(800, 1),
            next(850, 2),
            next(900, 3),
            next(1050, 1)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            Subscription(450, 700),
            Subscription(700, 950),
            Subscription(950, 1100)
            ])
    }
    
    func testRetryCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(5, 1),
            next(10, 2),
            next(15, 3),
            error(20, testError)
            ])
        
        let res = scheduler.start {
            xs.retry(3)
        }
        
        XCTAssertEqual(res.messages, [
            next(205, 1),
            next(210, 2),
            next(215, 3),
            next(225, 1),
            next(230, 2),
            next(235, 3),
            next(245, 1),
            next(250, 2),
            next(255, 3),
            error(260, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220),
            Subscription(220, 240),
            Subscription(240, 260)
            ])
    }

    func testRetryCount_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(5, 1),
            next(10, 2),
            next(15, 3),
            error(20, testError)
            ])
        
        let res = scheduler.start(231) {
            xs.retry(3)
        }
        
        XCTAssertEqual(res.messages, [
            next(205, 1),
            next(210, 2),
            next(215, 3),
            next(225, 1),
            next(230, 2),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220),
            Subscription(220, 231),
            ])
    }
    
    func testRetryCount_Infinite() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(5, 1),
            next(10, 2),
            next(15, 3),
            error(20, testError)
            ])
        
        let res = scheduler.start(231) {
            xs.retry(3)
        }
        
        XCTAssertEqual(res.messages, [
            next(205, 1),
            next(210, 2),
            next(215, 3),
            next(225, 1),
            next(230, 2),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220),
            Subscription(220, 231),
            ])
    }
    
    func testRetryCount_Completed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.retry(3)
        }
        
        XCTAssertEqual(res.messages, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            ])
    }

    func testRetry_tailRecursiveOptimizationsTest() {
        var count = 1
        let sequenceSendingImmediateError: Observable<Int> = create { observer in
            observer.on(.Next(0))
            observer.on(.Next(1))
            observer.on(.Next(2))
            if count < 2 {
                observer.on(.Error(testError))
                count++
            }
            observer.on(.Next(3))
            observer.on(.Next(4))
            observer.on(.Next(5))
            observer.on(.Completed)

            return NopDisposable.instance
        }

        _ = sequenceSendingImmediateError
            .retry()
            .subscribe { _ in
            }
    }
}

struct CustomErrorType : ErrorType {

}

// retryWhen
extension ObservableSingleTest {

    func testRetryWhen_Never() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let empty = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let res = scheduler.start(300) {
            xs.retryWhen { (errors: Observable<NSError>) in
                return empty
            }
        }
        
        let correct: [Recorded<Int>] = [
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testRetryWhen_ObservableNever() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            error(250, testError)
            ])
        
        let never = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<NSError>) in
                return never
            }
        }
        
        let correct: [Recorded<Int>] = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testRetryWhen_ObservableNeverComplete() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let never = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<NSError>) in
                return never
            }
        }
        
        let correct: [Recorded<Int>] = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testRetryWhen_ObservableEmpty() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            completed(250)
            ])
        
        let empty = scheduler.createHotObservable([
            next(150, 0),
            completed(0)
            ])
        
        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<NSError>) in
                return empty
            }
        }
        
        let correct: [Recorded<Int>] = [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450)
            ])
    }
    
    
    func testRetryWhen_ObservableNextError() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, testError),
            completed(40)
            ])
        
        let res = scheduler.start(300) {
            xs.retryWhen { (errors: Observable<NSError>) in
                return errors.scan(0) { (var a, e) in
                    if ++a == 2 {
                        throw testError1
                    }
                    return a
                }
            }
        }
        
        let correct: [Recorded<Int>] = [
            next(210, 1),
            next(220, 2),
            next(240, 1),
            next(250, 2),
            error(260, testError1)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230),
            Subscription(230, 260)
            ])
    }
    
    
    func testRetryWhen_ObservableComplete() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, testError),
            completed(40)
            ])
        
        let empty = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
            ])
        
        let res = scheduler.start() {
            xs.retryWhen({ (errors: Observable<NSError>) in
                return empty.asObservable()
            })
        }
        
        let correct: [Recorded<Int>] = [
            next(210, 1),
            next(220, 2),
            completed(230)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testRetryWhen_ObservableNextComplete() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, testError),
            completed(40)
            ])
        
        let res = scheduler.start(300) {
            xs.retryWhen { (errors: Observable<NSError>) in
                return errors.scan(0) { (a, e) in
                    return a + 1
                }.takeWhile { (num: Int) -> Bool in
                    return num < 2
                }
            }
        }
        
        let correct: [Recorded<Int>] = [
            next(210, 1),
            next(220, 2),
            next(240, 1),
            next(250, 2),
            completed(260)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230),
            Subscription(230, 260)
            ])
    }
    
    func testRetryWhen_ObservableInfinite() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, testError),
            completed(40)
            ])
        
        let never = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<NSError>) in
                return never
            }
        }
        
        let correct: [Recorded<Int>] = [
            next(210, 1),
            next(220, 2)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
    

    func testRetryWhen_Incremental_BackOff() {
        
        let scheduler = TestScheduler(initialClock: 0)
        
        // just fails
        let xs = scheduler.createColdObservable([
            next(5, 1),
            error(10, testError)
            ])
        
        let res = scheduler.start(800) {
            xs.retryWhen { (errors: Observable<NSError>) in
                errors.scan((0, nil)) { (a: (Int, NSError!), e) in
                    (a.0 + 1, e)
                }
                .flatMap { (a, e) -> Observable<Int64> in
                    if a >= 4 {
                        return failWith(e)
                    }

                    return timer(a * 50, scheduler)
                }
            }
        }
        
        let correct: [Recorded<Int>] = [
            next(205, 1),
            next(265, 1),
            next(375, 1),
            next(535, 1),
            error(540, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210),
            Subscription(260, 270),
            Subscription(370, 380),
            Subscription(530, 540)
            ])
    }

    func testRetryWhen_IgnoresDifferentErrorTypes() {

        let scheduler = TestScheduler(initialClock: 0)

        // just fails
        let xs = scheduler.createColdObservable([
            next(5, 1),
            error(10, testError)
            ])

        let res = scheduler.start(800) {
            xs.retryWhen { (errors: Observable<CustomErrorType>) in
                errors
            }
        }

        let correct: [Recorded<Int>] = [
            next(205, 1),
            error(210, testError)
        ]

        XCTAssertEqual(res.messages, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testRetryWhen_tailRecursiveOptimizationsTest() {
        var count = 1
        let sequenceSendingImmediateError: Observable<Int> = create { observer in
            observer.on(.Next(0))
            observer.on(.Next(1))
            observer.on(.Next(2))
            if count < 2 {
                observer.on(.Error(testError))
                count++
            }
            observer.on(.Next(3))
            observer.on(.Next(4))
            observer.on(.Next(5))
            observer.on(.Completed)

            return NopDisposable.instance
        }

        _ = sequenceSendingImmediateError
            .retryWhen { errors in
                return errors
            }
            .subscribe { _ in
        }
    }
}



// scan

extension ObservableSingleTest {
    func testScan_Seed_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(0, 0)
            ])
        
        let seed = 42
        
        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }
        
        XCTAssertEqual(res.messages, [
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testScan_Seed_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let seed = 42
        
        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }
        
        XCTAssertEqual(res.messages, [
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testScan_Seed_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(250)
            ])
        
        let seed = 42
        
        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }
        
        XCTAssertEqual(res.messages, [
            next(220, seed + 2),
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testScan_Seed_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError)
            ])
        
        let seed = 42
        
        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }
        
        XCTAssertEqual(res.messages, [
            error(250, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testScan_Seed_SomeData() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let seed = 42
        
        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }
        
        let messages: [Recorded<Int>] = [
            next(210, seed + 2),
            next(220, seed + 2 + 3),
            next(230, seed + 2 + 3 + 4),
            next(240, seed + 2 + 3 + 4 + 5),
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testScan_Seed_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let seed = 42
        
        let res = scheduler.start {
            xs.scan(seed) { (a, e) in
                if e == 4 {
                    throw testError
                } else {
                    return a + e
                }
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(210, seed + 2),
            next(220, seed + 2 + 3),
            error(230, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
}