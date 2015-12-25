//
//  Observable+SingleTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTests

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
        
        let ys = xs.asObservable()
        
        XCTAssert(xs !== ys)
        
        let res = scheduler.start { ys }
     
        let correct = [
            next(220, 2),
            completed(250)
        ]
 
        XCTAssertEqual(res.events, correct)
    }

    func testAsObservable_hides() {
        let xs = PrimitiveHotObservable<Int>()
        
        let res = xs.asObservable()
        
        XCTAssertTrue(res !== xs)
    }
    
    func testAsObservable_never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs : Observable<Int> = Observable.never()
        
        let res = scheduler.start { xs }
     
        let correct: [Recorded<Event<Int>>] = []
        
        XCTAssertEqual(res.events, correct)
    }
    
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
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}

// doOn
extension ObservableSingleTest {
    func testDoOn_shouldSeeAllValues() {
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
                    i += 1
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
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOn_plainAction() {
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
                i += 1
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
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOn_nextCompleted() {
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
                i += 1
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
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDoOn_completedNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let recordedEvents: [Recorded<Event<Int>>] = [
        ]
        
        let xs = scheduler.createHotObservable(recordedEvents)
        
        var i = 0
        var completedEvaluation = false
        let res = scheduler.start { xs.doOn { e in
            switch e {
            case .Next(_):
                i += 1
            case .Completed:
                completedEvaluation = true
            default: break
            }
            }
        }
        
        XCTAssertEqual(i, 0)
        XCTAssertEqual(completedEvaluation, false)
        
        let correctMessages: [Recorded<Event<Int>>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDoOn_nextError() {
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
                i += 1
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
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDoOn_nextErrorNot() {
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
                i += 1
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
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDoOn_Throws() {
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
            error(210, testError, Int.self)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 210)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOnNext_normal() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var numberOfTimesInvoked = 0

        let res = scheduler.start { xs.doOnNext { error in
                numberOfTimesInvoked = numberOfTimesInvoked + 1
            }
        }

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

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(numberOfTimesInvoked, 4)
    }

    func testDoOnNext_throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var numberOfTimesInvoked = 0

        let res = scheduler.start { xs.doOnNext { error in
                if numberOfTimesInvoked > 2 {
                    throw testError
                }
                numberOfTimesInvoked = numberOfTimesInvoked + 1
            }
        }

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            error(240, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 240)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(numberOfTimesInvoked, 3)
    }

    func testDoOnError_normal() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(250, testError)
            ])

        var recordedError: ErrorType!
        var numberOfTimesInvoked = 0

        let res = scheduler.start { xs.doOnError { error in
                recordedError = error
                numberOfTimesInvoked = numberOfTimesInvoked + 1
            }
        }

        let correctMessages = [
            next(210, 2),
            error(250, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(recordedError as NSError, testError)
        XCTAssertEqual(numberOfTimesInvoked, 1)
    }

    func testDoOnError_throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(250, testError)
            ])

        let res = scheduler.start { xs.doOnError { _ in
                throw testError1
            }
        }

        let correctMessages = [
            next(210, 2),
            error(250, testError1)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOnCompleted_normal() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var didComplete = false

        let res = scheduler.start { xs.doOnCompleted { error in
                didComplete = true
            }
        }

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

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(didComplete, true)
    }

    func testDoOnCompleted_throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        let res = scheduler.start { xs.doOnCompleted { error in
                throw testError
            }
        }

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

        XCTAssertEqual(res.events, correctMessages)
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        let sequenceSendingImmediateError: Observable<Int> = Observable.create { observer in
            observer.on(.Next(0))
            observer.on(.Next(1))
            observer.on(.Next(2))
            if count < 2 {
                observer.on(.Error(testError))
                count += 1
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
        
        let correct = [
            completed(250, Int.self)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
        
        let correct = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
        
        let correct = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
        
        let correct = [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
                return errors.scan(0) { (_a, e) in
                    var a = _a
                    a += 1
                    if a == 2 {
                        throw testError1
                    }
                    return a
                }
            }
        }
        
        let correct = [
            next(210, 1),
            next(220, 2),
            next(240, 1),
            next(250, 2),
            error(260, testError1)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
        
        let correct = [
            next(210, 1),
            next(220, 2),
            completed(230)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
        
        let correct = [
            next(210, 1),
            next(220, 2),
            next(240, 1),
            next(250, 2),
            completed(260)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
        
        let correct = [
            next(210, 1),
            next(220, 2)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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
                        return Observable.error(e)
                    }

                    return Observable<Int64>.timer(RxTimeInterval(a * 50), scheduler: scheduler)
                }
            }
        }
        
        let correct = [
            next(205, 1),
            next(265, 1),
            next(375, 1),
            next(535, 1),
            error(540, testError)
        ]
        
        XCTAssertEqual(res.events, correct)
        
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

        let correct = [
            next(205, 1),
            error(210, testError)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testRetryWhen_tailRecursiveOptimizationsTest() {
        var count = 1
        let sequenceSendingImmediateError: Observable<Int> = Observable.create { observer in
            observer.on(.Next(0))
            observer.on(.Next(1))
            observer.on(.Next(2))
            if count < 2 {
                observer.on(.Error(testError))
                count += 1
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(res.events, [
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
        
        let messages = [
            next(210, seed + 2),
            next(220, seed + 2 + 3),
            next(230, seed + 2 + 3 + 4),
            next(240, seed + 2 + 3 + 4 + 5),
            completed(250)
        ]
        
        XCTAssertEqual(res.events, messages)
        
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
        
        XCTAssertEqual(res.events, [
            next(210, seed + 2),
            next(220, seed + 2 + 3),
            error(230, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
}

// groupBy

extension ObservableSingleTest {
    func testGroupBy_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(50, 1),
            error(205, testError)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<Bool, Int>> = xs.groupBy { _ in true }
            let mappedWithIndex = group.mapWithIndex { (go: GroupedObservable<Bool, Int>, i: Int) -> Observable<String> in
                return go.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            error(205, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 205)
            ])
    }
    
    func testGroupBy_OneGroup() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<Bool, Int>> = xs.groupBy { _ in true }
            let mappedWithIndex = group.mapWithIndex { (go: GroupedObservable<Bool, Int>, i: Int) -> Observable<String> in
                return go.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "0 2"),
            next(240, "0 3"),
            next(280, "0 4"),
            next(320, "0 5"),
            next(350, "0 6"),
            next(370, "0 7"),
            next(420, "0 8"),
            next(470, "0 9"),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }

    func testGroupBy_TwoGroup() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<Int, Int>> = xs.groupBy { x in x % 2 }
            let mappedWithIndex = group.mapWithIndex { (go: GroupedObservable<Int, Int>, i: Int) -> Observable<String> in
                return go.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "1 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "0 5"),
            next(350, "1 6"),
            next(370, "0 7"),
            next(420, "1 8"),
            next(470, "0 9"),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testGroupBy_WithKeyComparer() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(90, "rab"),
            next(110, "aaf"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked++
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz"),
            next(360, "qux"),
            completed(570)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
        
        XCTAssertEqual(keyInvoked, 12)
    }
    
    func testGroupBy_OuterError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            error(570, testError),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked++
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz"),
            next(360, "qux"),
            error(570, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
        
        XCTAssertEqual(keyInvoked, 12)
    }

    
    func testGroupBy_OuterDispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        let res = scheduler.start(355) { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked++
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz")
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 355)
            ])
        
        XCTAssertEqual(keyInvoked, 5)
    }
    
    func testGroupBy_OuterKeySelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            error(570, testError),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked++
                if keyInvoked == 10 {
                    throw testError
                }
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz"),
            next(360, "qux"),
            error(480, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 480)
            ])
        
        XCTAssertEqual(keyInvoked, 10)
    }
    
    func testGroupBy_InnerComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])

        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()

        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            outerSubscription = outer.subscribeNext({ (group: GroupedObservable<String, String>) -> Void in
                let result: MockObserver<String> = scheduler.createObserver(String)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = scheduler.scheduleRelative((), dueTime: 100, action: { _ in
                    group.subscribe(result)
                })
            })
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
            
        }
        
        scheduler.start()

        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)])

        XCTAssertEqual(results["bar"]!.events, [
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])

        XCTAssertEqual(results["baz"]!.events, [
            next(480, "baz  "),
            next(510, " bAZ "),
            completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }
    
    func testGroupBy_InnerCompleteAll() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            outerSubscription = outer.subscribeNext({ (group: GroupedObservable<String, String>) -> Void in
                let result: MockObserver<String> = scheduler.createObserver(String)
                inners[group.key] = group
                results[group.key] = result
                innerSubscriptions[group.key] = group.subscribe(result)
            })
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)])

        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   "),
            next(480, "baz  "),
            next(510, " bAZ "),
            completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux "),
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            error(570, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            outerSubscription = outer.subscribeNext({ (group: GroupedObservable<String, String>) -> Void in
                let result: MockObserver<String> = scheduler.createObserver(String)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = scheduler.scheduleRelative((), dueTime: 100, action: { _ in
                     group.subscribe(result)
                })
            })
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(470, "FOO "),
            next(530, "    fOo    "),
            error(570, testError)])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(390, "   bar"),
            next(420, " BAR  "),
            error(570, testError)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(480, "baz  "),
            next(510, " bAZ "),
            error(570, testError)])
        
        XCTAssertEqual(results["qux"]!.events, [
            error(570, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }

    func testGroupBy_InnerDispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            outerSubscription = outer.subscribeNext { (group: GroupedObservable<String, String>) -> Void in
                let result: MockObserver<String> = scheduler.createObserver(String)
                inners[group.key] = group
                results[group.key] = result
                innerSubscriptions[group.key] = group.subscribe(result)
            }
        }
        
        scheduler.scheduleAt(400) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar")])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   ")])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux ")])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testGroupBy_InnerKeyThrow() {
        let scheduler = TestScheduler(initialClock: 0)

        var keyInvoked = 0

        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                keyInvoked++
                if keyInvoked == 6 {
                    throw testError
                }
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!.subscribeNext { (group: GroupedObservable<String, String>) -> Void in
                let result: MockObserver<String> = scheduler.createObserver(String)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = group.subscribe(result)
            }
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 3)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            error(360, testError)])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            error(360, testError)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   "),
            error(360, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 360)
            ])
    }
    
    func testGroupBy_OuterIndependence() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()
        let outerResults: MockObserver<String> = scheduler.createObserver(String)
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        outerResults.onNext(group.key)
                        
                        let result: MockObserver<String> = scheduler.createObserver(String)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = group.subscribe(result)
                    },
                    onError: { (e) -> Void in
                        outerResults.onError(e)
                    },
                    onCompleted: {
                        outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }

        scheduler.scheduleAt(320) {
            outerSubscription?.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 2)
        
        XCTAssertEqual(outerResults.events, [
            next(220, "foo"),
            next(270, "bar")])
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }
    
    func testGroupBy_InnerIndependence() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()
        let outerResults: MockObserver<String> = scheduler.createObserver(String)
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            outerSubscription = outer
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        outerResults.onNext(group.key)
                        
                        let result: MockObserver<String> = scheduler.createObserver(String)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = group.subscribe(result)
                    },
                    onError: { (e) -> Void in
                        outerResults.onError(e)
                    },
                    onCompleted: {
                        outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.scheduleAt(320) {
            innerSubscriptions["foo"]!.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   "),
            next(480, "baz  "),
            next(510, " bAZ "),
            completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux "),
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerMultipleIndependence() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, MockObserver<String>>()
        let outerResults: MockObserver<String> = scheduler.createObserver(String)
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            outerSubscription = outer
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        outerResults.onNext(group.key)
                        
                        let result: MockObserver<String> = scheduler.createObserver(String)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = group.subscribe(result)
                    },
                    onError: { (e) -> Void in
                        outerResults.onError(e)
                    },
                    onCompleted: {
                        outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.scheduleAt(320) {
            innerSubscriptions["foo"]!.dispose()
        }
        
        scheduler.scheduleAt(280) {
            innerSubscriptions["bar"]!.dispose()
        }

        scheduler.scheduleAt(355) {
            innerSubscriptions["baz"]!.dispose()
        }

        scheduler.scheduleAt(400) { () -> Void in
            innerSubscriptions["qux"]!.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  ")])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   ")])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux ")])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        let results: MockObserver<String> = scheduler.createObserver(String)
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!.subscribeNext({ (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        scheduler.scheduleAt(600) {
            innerSubscription = inner?.subscribe(results)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            innerSubscription?.dispose()
        }
        
        scheduler.start()

        XCTAssertEqual(results.events, [
            completed(600)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            error(570, testError)
            ])
        
        let results: MockObserver<String> = scheduler.createObserver(String)
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!.subscribeNext({ (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        scheduler.scheduleAt(600) {
            innerSubscription = inner?.subscribe(results)
        }
        
        scheduler.scheduleAt(Defaults.disposed) { () -> Void in
            outerSubscription?.dispose()
            innerSubscription?.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            error(600, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeDispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            error(570, testError)
            ])
        
        let results: MockObserver<String> = scheduler.createObserver(String)
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            outerSubscription = outer.subscribeNext({ (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        scheduler.scheduleAt(400) {
            outerSubscription?.dispose()
        }

        scheduler.scheduleAt(600) {
            innerSubscription = inner?.subscribe(results)
        }

        scheduler.scheduleAt(Defaults.disposed) {
            innerSubscription?.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(results.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)])
    }
    
    func testGroupBy_WithRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let start = NSDate()
        
        let a = try! Observable<Int64>.interval(1, scheduler: scheduler)
            .take(5)
            .groupBy { return $0 % 3 }
            .toBlocking()
            .toArray()
        
        let end = NSDate()
        
        let b = a.map { (go: GroupedObservable<Int64, Int64>) -> Int64 in
            return go.key
        }
        
        XCTAssertEqualWithAccuracy(5, end.timeIntervalSinceDate(start), accuracy: 0.5)
        XCTAssertEqual(b, [0, 1, 2])
    }

    
    func testGroupBy_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(0, 0)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<Bool, Int>> = xs.groupBy { _ in true }
            let mappedWithIndex = group.mapWithIndex({ (go: GroupedObservable<Bool, Int>, i: Int) -> Observable<String> in
                return go.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            })
            return mappedWithIndex.merge()
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testGroupBy_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<Bool, Int>> = xs.groupBy { _ in true }
            let mappedWithIndex = group.mapWithIndex({ (go: GroupedObservable<Bool, Int>, i: Int) -> Observable<String> in
                return go.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            })
            return mappedWithIndex.merge()
        }
        
        XCTAssertEqual(res.events, [
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

}
