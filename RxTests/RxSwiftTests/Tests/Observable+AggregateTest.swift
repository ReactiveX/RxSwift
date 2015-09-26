//
//  Observable+AggregateTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class ObservableAggregateTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

extension ObservableAggregateTest {
    func test_AggregateWithSeed_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages = [
            next(250, 42),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 24),
            completed(250)
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages = [
            next(250, 42 + 24),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_AggregateWithSeed_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError),
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages: [Recorded<Int>] = [
            error(210, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 210)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages: [Recorded<Int>] = [
            next(260, 42 + 0 + 1 + 2 + 3 + 4),
            completed(260)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 260)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start {
            xs.reduce(42) { (a: Int, x: Int) throws -> Int in
                if x < 3 {
                    return a + x
                }
                else {
                    throw testError
                }
            }
        }
        
        let correctMessages: [Recorded<Int>] = [
            error(240, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 240)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start { xs.reduce(42, +) { $0 * 5 } }
        
        let correctMessages = [
            next(250, 42 * 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 24),
            completed(250)
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages = [
            next(250, (42 + 24) * 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError),
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
            error(210, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 210)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
   
    func test_AggregateWithSeedAndResult_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
            next(260, (42 + 0 + 1 + 2 + 3 + 4) * 5),
            completed(260)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 260)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, { a, x in if x < 3 { return a + x } else { throw testError } }, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
            error(240, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 240)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { (_: Int) throws -> Int in throw testError }) }
        
        let correctMessages: [Recorded<Int>] = [
            error(260, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 260)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}





class ObservableAverageTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}


extension ObservableAverageTest {
    func test_AverageInteger_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.average() }
        
        let correctMessages: [Recorded<Double>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AverageInteger_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        XCTAssertEqual(res.messages[0].time, 250)
        XCTAssertTrue(res.messages[0].value.isNaN)
        XCTAssertEqual(res.messages[1], completed(250))
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func test_AverageInteger_Single() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        let messages: [Recorded<Double>] = [
            next(220, 2.0),
            completed(220)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220)
            ])
    }
    
    func test_AverageInteger_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        let messages: [Recorded<Double>] = [
            next(250, 3.5),
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func test_AverageFloat_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Float(1)),
            ])
        
        let res = scheduler.start { xs.average() }
        
        let correctMessages: [Recorded<Float>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AverageFloat_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Float(1.111)),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        XCTAssertEqual(res.messages[0].time, 250)
        XCTAssertTrue(res.messages[0].value.isNaN)
        XCTAssertEqual(res.messages[1], completed(250))
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func test_AverageFloat_Single() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Float(1.111)),
            next(210, Float(2.0)),
            completed(220)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        let messages: [Recorded<Float>] = [
            next(220, 2.0),
            completed(220)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220)
            ])
    }

    func test_AverageFloat_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Float(1.111)),
            next(210, Float(2.22)),
            next(220, Float(3.33)),
            next(230, Float(4.33)),
            next(240, Float(5.111)),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        let messages: [Recorded<Float>] = [
            next(250, 3.74775),
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func test_AverageDouble_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Double(1)),
            ])
        
        let res = scheduler.start { xs.average() }
        
        let correctMessages: [Recorded<Double>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AverageDouble_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Double(1.111)),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        XCTAssertEqual(res.messages[0].time, 250)
        XCTAssertTrue(res.messages[0].value.isNaN)
        XCTAssertEqual(res.messages[1], completed(250))
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func test_AverageDouble_Single() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Double(1.111)),
            next(210, Double(2.0)),
            completed(220)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        let messages: [Recorded<Double>] = [
            next(220, 2.0),
            completed(220)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220)
            ])
    }
    
    func test_AverageDouble_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Double(1.111)),
            next(210, Double(2.22)),
            next(220, Double(3.33)),
            next(230, Double(4.33)),
            next(240, Double(5.111)),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.average()
        }
        
        let messages: [Recorded<Double>] = [
            next(250, 3.74775),
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

}
