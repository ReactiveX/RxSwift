//
//  Observable+StandardSequenceOperatorsTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTests
#if os(Linux)
import Glibc
#endif

class ObservableStandardSequenceOperatorsTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

func isPrime(i: Int) -> Bool {
    if i <= 1 {
        return false
    }
    
    let max = Int(sqrt(Double(i)))
    if max <= 1 {
        return true
    }

    for j in 2 ... max {
        if i % j == 0 {
            return false
        }
    }
    
    return true
}

// MARK: where
extension ObservableStandardSequenceOperatorsTest  {
    func test_filterComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600),
            next(610, 12),
            error(620, testError),
            completed(630)
        ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.filter { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num);
            }
        }
        
        XCTAssertEqual(res.events, [
            next(230, 3),
            next(340, 5),
            next(390, 7),
            next(580, 11),
            completed(600)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
        ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_filterTrue() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.filter { (num: Int) -> Bool in
                invoked += 1
                return true
            }
        }
        
        XCTAssertEqual(res.events, [
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(9, invoked)
    }
   
    func test_filterFalse() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.filter { (num: Int) -> Bool in
                invoked += 1
                return false
            }
        }
        
        XCTAssertEqual(res.events, [
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_filterDisposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start(400) { () -> Observable<Int> in
            return xs.filter { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(230, 3),
            next(340, 5),
            next(390, 7)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(5, invoked)
    }
}

// MARK: takeWhile
extension ObservableStandardSequenceOperatorsTest {
    func testTakeWhile_Complete_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            completed(330),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
        ])
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            completed(330)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 330)
        ])
        
        XCTAssertEqual(4, invoked)
    }
    
    func testTakeWhile_Complete_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Error_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            error(270, testError),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            error(270, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
        
        XCTAssertEqual(2, invoked)
    }
    
    func testTakeWhile_Error_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Dispose_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start(300) { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testTakeWhile_Dispose_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start(400) { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            completed(390)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testTakeWhile_Zero() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError),
            ])
        
        var invoked = 0
        
        let res = scheduler.start(300) { () -> Observable<Int> in
            return xs.takeWhile { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            completed(205)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 205)
            ])
        
        XCTAssertEqual(1, invoked)
    }
    
    func testTakeWhile_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
 
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() { () -> Observable<Int> in
            return xs.takeWhile { num in
                invoked += 1
                
                if invoked == 3 {
                    throw testError
                }
                
                return isPrime(num)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(260, 5),
            error(290, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testTakeWhile_Index1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError),
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num, index in index < 5 }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            completed(350)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
        ])
    }
    
    func testTakeWhile_Index2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            completed(400)
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num , index  in return index >= 0 }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            completed(400)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testTakeWhile_Index_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            error(400, testError)
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num, index in index >= 0 }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            error(400, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    
    func testTakeWhile_Index_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            completed(400)
            ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.takeWhileWithIndex { num, index in
                if index < 5 {
                    return true
                }
                
                throw testError
            }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            error(350, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
            ])
    }
    
}

// MARK: map
extension ObservableStandardSequenceOperatorsTest {
    func testMap_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.map { $0 * 2 } }
        
        let correctMessages: [Recorded<Event<Int>>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])
        
        let res = scheduler.start { xs.map { $0 * 2 } }
        
        let correctMessages = [
            completed(300, Int.self)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start { xs.map { $0 * 2 } }
        
        let correctMessages = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start { xs.map { $0 * 2 } }
        
        let correctMessages = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
            error(300, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start(290) { xs.map { $0 * 2 } }
        
        let correctMessages = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
        ]
        
        let correctSubscriptions = [
            Subscription(200, 290)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start { xs.map { x throws -> Int in if x < 2 { return x * 2 } else { throw testError } } }
        
        let correctMessages = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            error(230, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 230)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages: [Recorded<Event<Int>>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap1_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])
        
        let res = scheduler.start { xs.mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages = [
            completed(300, Int.self)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start { xs.mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            next(230, (7 + 2) * 2),
            next(240, (8 + 3) * 2),
            completed(300)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start { xs.mapWithIndex { ($0 + $1) * 2 }  }
        
        let correctMessages = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            next(230, (7 + 2) * 2),
            next(240, (8 + 3) * 2),
            error(300, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start(290) { xs.mapWithIndex { ($0 + $1) * 2 } }
        
        let correctMessages = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            next(230, (7 + 2) * 2),
            next(240, (8 + 3) * 2),
        ]
        
        let correctSubscriptions = [
            Subscription(200, 290)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
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
        
        let res = scheduler.start { xs.mapWithIndex { x, i throws -> Int in if x < 7 { return ((x + i) * 2) } else { throw testError } } }
        
        let correctMessages = [
            next(210, (5 + 0) * 2),
            next(220, (6 + 1) * 2),
            error(230, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 230)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testMap_DisposeOnCompleted() {
        _ = Observable.just("A")
            .map { a in
                return a
            }
            .subscribeNext { _ in
                
            }
    }
    
    func testMap1_DisposeOnCompleted() {
        _ = Observable.just("A")
            .mapWithIndex { (a, i) in
                return a
            }
            .subscribeNext { _ in
                
            }
    }
}

// MARK: map compose
extension ObservableStandardSequenceOperatorsTest {
    func testMapCompose_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])

        let res = scheduler.start { xs.map { $0 * 10 }.map { $0 + 1 } }

        let correctMessages: [Recorded<Event<Int>>] = [
        ]

        let correctSubscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testMapCompose_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])

        let res = scheduler.start { xs.map { $0 * 10 }.map { $0 + 1 } }

        let correctMessages = [
            completed(300, Int.self)
        ]

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testMapCompose_Range() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            completed(300)
            ])

        let res = scheduler.start { xs.map { $0 * 10 }.map { $0 + 1 } }

        let correctMessages = [
            next(210, 0 * 10 + 1),
            next(220, 1 * 10 + 1),
            next(230, 2 * 10 + 1),
            next(240, 4 * 10 + 1),
            completed(300)
        ]

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testMapCompose_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            error(300, testError)
            ])

        let res = scheduler.start { xs.map { $0 * 10 }.map { $0 + 1 } }

        let correctMessages = [
            next(210, 0 * 10 + 1),
            next(220, 1 * 10 + 1),
            next(230, 2 * 10 + 1),
            next(240, 4 * 10 + 1),
            error(300, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testMapCompose_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            error(300, testError)
            ])

        let res = scheduler.start(290) { xs.map { $0 * 10 }.map { $0 + 1 } }

        let correctMessages = [
            next(210, 0 * 10 + 1),
            next(220, 1 * 10 + 1),
            next(230, 2 * 10 + 1),
            next(240, 4 * 10 + 1),
        ]

        let correctSubscriptions = [
            Subscription(200, 290)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testMapCompose_Selector1Throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            error(300, testError)
            ])

        let res = scheduler.start {
            xs
            .map { x throws -> Int in if x < 2 { return x * 10 } else { throw testError } }
            .map { $0 + 1 }
        }

        let correctMessages = [
            next(210, 0 * 10 + 1),
            next(220, 1 * 10 + 1),
            error(230, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 230)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testMapCompose_Selector2Throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            error(300, testError)
            ])

        let res = scheduler.start {
            xs
                .map { $0 * 10 }
                .map { x throws -> Int in if x < 20 { return x + 1 } else { throw testError } }
        }

        let correctMessages = [
            next(210, 0 * 10 + 1),
            next(220, 1 * 10 + 1),
            error(230, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 230)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    #if TRACE_RESOURCES
    func testMapCompose_OptimizationIsPerformed() {
        let scheduler = TestScheduler(initialClock: 0)

        var checked = false
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            ])

        let res = scheduler.start {
            xs
                .map { $0 * 10 }
                .map { x -> Int in
                    checked = true
                    XCTAssertTrue(numberOfMapOperators == 1)
                    return x + 1
                }
        }

        let correctMessages = [
            next(210, 0 * 10 + 1),
        ]

        let correctSubscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertTrue(checked)
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testMapCompose_OptimizationIsNotPerformed() {
        let scheduler = TestScheduler(initialClock: 0)

        var checked = false
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            ])

        let res = scheduler.start {
            xs
                .map { $0 * 10 }
                .filter { _ in true }
                .map { x -> Int in
                    checked = true
                    XCTAssertTrue(numberOfMapOperators == 2)
                    return x + 1
            }
        }

        let correctMessages = [
            next(210, 0 * 10 + 1),
        ]

        let correctSubscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertTrue(checked)
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    #endif
}

// MARK: flatMapFirst
extension ObservableStandardSequenceOperatorsTest {

    func testFlatMapFirst_Complete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
            ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
            ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
            ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
            ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
            ])),
            next(750, scheduler.createColdObservable([
                completed(40)
            ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
            ])),
            completed(900)
        ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(740, 106),
            next(930, 401),
            next(940, 402),
            completed(950)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
        ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
        ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
        ])
    }


    func testFlatMapFirst_Complete_InnerNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(740, 106),
            next(930, 401),
            next(940, 402),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }

    func testFlatMapFirst_Complete_OuterNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(740, 106),
            next(930, 401),
            next(940, 402),
            completed(950),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }


    func testFlatMapFirst_Complete_ErrorOuter() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            error(900, testError)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(740, 106),
            error(900, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 900)
            ])
    }

    func testFlatMapFirst_Error_Inner() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                error(460, testError)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(740, 106),
            error(760, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }

    func testFlatMapFirst_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])

        let res = scheduler.start(700) {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 700)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 700)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [])
    }

    func testFlatMapFirst_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])

        var invoked = 0
        let res = scheduler.start {
            return xs.flatMapFirst { (x: TestableObservable<Int>) -> TestableObservable<Int> in
                invoked += 1
                if invoked == 2 {
                    throw testError
                }
                return x
            }
        }

        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(740, 106),
            error(850, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 850)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [])
    }

    func testFlatMapFirst_UseFunction() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 4),
            next(220, 3),
            next(250, 5),
            next(270, 1),
            completed(290)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { (x) in
                return Observable<Int64>.interval(10, scheduler: scheduler).map { _ in x } .take(x)
            }
        }

        XCTAssertEqual(res.events, [
            next(220, 4),
            next(230, 4),
            next(240, 4),
            next(250, 4),
            next(280, 1),
            completed(290)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
    }
}

// MARK: flatMap
extension ObservableStandardSequenceOperatorsTest {
    
    func testFlatMap_Complete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
            ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
            ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
            ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
            ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
            ])),
            next(750, scheduler.createColdObservable([
                completed(40)
            ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
            ])),
            completed(900)
        ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            next(930, 401),
            next(940, 402),
            completed(960)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
        ])

    
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
        ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
        ])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
        ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
        ])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
        ])
    }
    
    func testFlatMap_Complete_InnerNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            next(930, 401),
            next(940, 402),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }
    
    func testFlatMap_Complete_OuterNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            next(930, 401),
            next(940, 402),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 1000)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }
    
    func testFlatMap_Complete_ErrorOuter() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            error(900, testError)
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            error(900, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 900)
            ])
    }
    
    func testFlatMap_Error_Inner() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                error(460, testError)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            error(760, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
    
    func testFlatMap_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        let res = scheduler.start(700) {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
   
    func testFlatMap_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        var invoked = 0
        let res = scheduler.start {
            return xs.flatMap { (x: TestableObservable<Int>) -> TestableObservable<Int> in
                invoked += 1
                if invoked == 3 {
                    throw testError
                }
                return x
            }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            error(550, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
    
    func testFlatMap_UseFunction() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 4),
            next(220, 3),
            next(250, 5),
            next(270, 1),
            completed(290)
            ])
        
        let res = scheduler.start {
            xs.flatMap { (x) in
                return Observable<Int64>.interval(10, scheduler: scheduler).map { _ in x } .take(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, 4),
            next(230, 3),
            next(230, 4),
            next(240, 3),
            next(240, 4),
            next(250, 3),
            next(250, 4),
            next(260, 5),
            next(270, 5),
            next(280, 1),
            next(280, 5),
            next(290, 5),
            next(300, 5),
            completed(300)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
    }
    
    func testFlatMapIndex_Index() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 4),
            next(220, 3),
            next(250, 5),
            next(270, 1),
            completed(290)
            ])
        
        let res = scheduler.start {
            xs.flatMapWithIndex { (x, i) in
                return Observable.just(ElementIndexPair(x, i))
            }
        }
        
        XCTAssertEqual(res.events, [
            next(210, ElementIndexPair(4, 0)),
            next(220, ElementIndexPair(3, 1)),
            next(250, ElementIndexPair(5, 2)),
            next(270, ElementIndexPair(1, 3)),
            completed(290)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
        ])
    }
    
    
    func testFlatMapWithIndex_Complete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        let res = scheduler.start {
            xs.flatMapWithIndex { x, _ in x }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            next(930, 401),
            next(940, 402),
            completed(960)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }
    
    func testFlatMapWithIndex_Complete_InnerNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            ])
        
        let res = scheduler.start {
            xs.flatMapWithIndex { x, _ in x }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            next(930, 401),
            next(940, 402),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }
    
    
    func testFlatMapWithIndex_Complete_OuterNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        let res = scheduler.start {
            xs.flatMapWithIndex { x, _ in x }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            next(930, 401),
            next(940, 402),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 1000)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }
    
    
    func testFlatMapWithIndex_Complete_ErrorOuter() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            error(900, testError)
            ])
        
        let res = scheduler.start {
            xs.flatMapWithIndex { x, _ in x }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            next(810, 304),
            next(860, 305),
            error(900, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 900)
            ])
    }
    
    func testFlatMapWithIndex_Error_Inner() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                error(460, testError)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        let res = scheduler.start {
            xs.flatMapWithIndex { x, _ in x }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            next(740, 106),
            error(760, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
    
    func testFlatMapWithIndex_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        let res = scheduler.start(700) {
            xs.flatMapWithIndex { x, _ in x }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            next(560, 301),
            next(580, 202),
            next(590, 203),
            next(600, 302),
            next(620, 303),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
    
    func testFlatMapWithIndex_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(5, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(105, scheduler.createColdObservable([
                error(1, testError)
                ])),
            next(300, scheduler.createColdObservable([
                next(10, 102),
                next(90, 103),
                next(110, 104),
                next(190, 105),
                next(440, 106),
                completed(460)
                ])),
            next(400, scheduler.createColdObservable([
                next(180, 202),
                next(190, 203),
                completed(205)
                ])),
            next(550, scheduler.createColdObservable([
                next(10, 301),
                next(50, 302),
                next(70, 303),
                next(260, 304),
                next(310, 305),
                completed(410)
                ])),
            next(750, scheduler.createColdObservable([
                completed(40)
                ])),
            next(850, scheduler.createColdObservable([
                next(80, 401),
                next(90, 402),
                completed(100)
                ])),
            completed(900)
            ])
        
        var invoked = 0
        let res = scheduler.start {
            return xs.flatMapWithIndex { (x: TestableObservable<Int>, _: Int) -> TestableObservable<Int> in
                invoked += 1
                if invoked == 3 {
                    throw testError
                }
                return x
            }
        }
        
        XCTAssertEqual(res.events, [
            next(310, 102),
            next(390, 103),
            next(410, 104),
            next(490, 105),
            error(550, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
    
    func testFlatMapWithIndex_UseFunction() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(210, 4),
            next(220, 3),
            next(250, 5),
            next(270, 1),
            completed(290)
            ])
        
        let res = scheduler.start {
            xs.flatMapWithIndex { (x, _) in
                return Observable<Int64>.interval(10, scheduler: scheduler).map { _ in x } .take(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, 4),
            next(230, 3),
            next(230, 4),
            next(240, 3),
            next(240, 4),
            next(250, 3),
            next(250, 4),
            next(260, 5),
            next(270, 5),
            next(280, 1),
            next(280, 5),
            next(290, 5),
            next(300, 5),
            completed(300)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
    }
    
}

// MARK: take

extension ObservableStandardSequenceOperatorsTest {
    func testTake_Complete_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.take(20)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }
    
    func testTake_Complete_Same() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.take(17)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(630)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 630)
            ])
    }
    
    func testTake_Complete_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.take(10)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            completed(415)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 415)
            ])
    }
    
    func testTake_Error_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.take(20)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }

    func testTake_Error_Same() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.take(17)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(630)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 630)
            ])
    }
    
    func testTake_Error_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.take(3)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            completed(270)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
    }
    
    func testTake_Dispose_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start(250) {
            xs.take(3)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testTake_Dispose_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start(400) {
            xs.take(3)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            completed(270)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
    }
    
    func testTake_0_DefaultScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13)
        ])
        
        let res = scheduler.start {
            xs.take(0)
        }
        
        XCTAssertEqual(res.events, [
            completed(200)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
        ])
    }
    
    func testTake_Take1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.take(3)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            completed(270)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
    }
    
    func testTake_DecrementCountsFirst() {
        let k = BehaviorSubject(value: false)
        
        _ = k.take(1).subscribeNext { n in
            k.on(.Next(!n))
        }
    }
}

// MARK: takeLast

extension ObservableStandardSequenceOperatorsTest {
    func testTakeLast_Complete_Less() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs.takeLast(7)
        }
        
        XCTAssertEqual(res.events, [
            next(300, 9),
            next(300, 13),
            next(300, 7),
            next(300, 1),
            next(300, -1),
            completed(300)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }
    
    func testTakeLast_Complete_Same() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            completed(310)
            ])
        
        let res = scheduler.start {
            xs.takeLast(5)
        }
        
        XCTAssertEqual(res.events, [
            next(310, 9),
            next(310, 13),
            next(310, 7),
            next(310, 1),
            next(310, -1),
            completed(310)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 310)
            ])
    }
    
    func testTakeLast_Complete_More() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            completed(350)
            ])
        
        let res = scheduler.start {
            xs.takeLast(5)
        }
        
        XCTAssertEqual(res.events, [
            next(350, 7),
            next(350, 1),
            next(350, -1),
            next(350, 3),
            next(350, 8),
            completed(350)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
            ])
    }
    
    func testTakeLast_Error_Less() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(290, 64),
            error(300, testError)
            ])
        
        let res = scheduler.start {
            xs.takeLast(7)
        }
        
        XCTAssertEqual(res.events, [
            error(300, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
    }
    
    func testTakeLast_Error_Same() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            error(310, testError)
            ])
        
        let res = scheduler.start {
            xs.takeLast(5)
        }
        
        XCTAssertEqual(res.events, [
            error(310, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 310)
            ])
    }
    
    func testTakeLast_Error_More() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 64),
            error(360, testError)
            ])
        
        let res = scheduler.start {
            xs.takeLast(5)
        }
        
        XCTAssertEqual(res.events, [
            error(360, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 360)
            ])
    }
    
    func testTakeLast_0_DefaultScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13)
            ])
        
        let res = scheduler.start {
            xs.takeLast(0)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testTakeLast_TakeLast1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.takeLast(3)
        }
        
        XCTAssertEqual(res.events, [
            next(400, 3),
            next(400, 8),
            next(400, 11),
            completed(400)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testTakeLast_DecrementCountsFirst() {
        let k = BehaviorSubject(value: false)

        var elements = [Bool]()
        _ = k.takeLast(1).subscribeNext { n in
            elements.append(n)
            k.on(.Next(!n))
        }

        k.on(.Completed)

        XCTAssertEqual(elements, [false])
    }
}

// MARK: skip
extension ObservableStandardSequenceOperatorsTest {
    func testSkip_Complete_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.skip(20)
        }
        
        XCTAssertEqual(res.events, [
            completed(690)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
        ])
    }
    
    
    func testSkip_Complete_Some() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.skip(17)
        }
        
        XCTAssertEqual(res.events, [
            completed(690)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }
    
    func testSkip_Complete_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.skip(10)
        }
        
        XCTAssertEqual(res.events, [
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }
    
    func testSkip_Complete_Zero() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.skip(0)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }
    
    func testSkip_Error_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.skip(20)
        }
        
        XCTAssertEqual(res.events, [
            error(690, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }
    
    func testSkip_Error_Same() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.skip(17)
        }
        
        XCTAssertEqual(res.events, [
            error(690, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }
    
    func testSkip_Error_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.skip(3)
        }
        
        XCTAssertEqual(res.events, [
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 690)
            ])
    }
    
    func testSkip_Dispose_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            ])
        
        let res = scheduler.start(250) {
            xs.skip(3)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSkip_Dispose_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            ])
        
        let res = scheduler.start(400) {
            xs.skip(3)
        }
        
        XCTAssertEqual(res.events, [
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
}

// MARK: SkipWhile
extension ObservableStandardSequenceOperatorsTest {

    func testSkipWhile_Complete_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            completed(330),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            completed(330)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 330)
            ])
        
        XCTAssertEqual(4, invoked)
    }
    
    func testSkipWhile_Complete_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testSkipWhile_Error_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            error(270, testError),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        
        
        XCTAssertEqual(res.events, [
            error(270, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 270)
            ])
        
        XCTAssertEqual(2, invoked)
    }
    
    func testSkipWhile_Error_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            error(600, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testSkipWhile_Dispose_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start(300) {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testSkipWhile_Dispose_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start(470) {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(390, 4),
            next(410, 17),
            next(450, 8)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 470)
            ])
        
        XCTAssertEqual(6, invoked)
    }
    
    func testSkipWhile_Zero() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
        
        XCTAssertEqual(1, invoked)
    }
    
    func testSkipWhile_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        var invoked = 0
        
        let res = scheduler.start() {
            xs.skipWhile { x in
                invoked += 1
                if invoked == 3 {
                    throw testError
                }
                return isPrime(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            error(290, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func testSkipWhile_Index() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        let res = scheduler.start() {
            xs.skipWhileWithIndex { x, i in i < 5 }
        }
        
        XCTAssertEqual(res.events, [
            next(350, 7),
            next(390, 4),
            next(410, 17),
            next(450, 8),
            next(500, 23),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testSkipWhile_Index_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            error(400, testError)
            ])
        
        let res = scheduler.start() {
            xs.skipWhileWithIndex { x, i in i < 5 }
        }
        
        XCTAssertEqual(res.events, [
            next(350, 7),
            next(390, 4),
            error(400, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testSkipWhile_Index_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, -1),
            next(110, -1),
            next(205, 100),
            next(210, 2),
            next(260, 5),
            next(290, 13),
            next(320, 3),
            next(350, 7),
            next(390, 4),
            completed(400)
            ])
        
        let res = scheduler.start() {
            xs.skipWhileWithIndex { x, i in
                if i < 5 {
                    return true
                }
                throw testError
            }
        }
        
        XCTAssertEqual(res.events, [
            error(350, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 350)
            ])
    }
}

// MARK: elementAt
extension ObservableStandardSequenceOperatorsTest {
    
    func testElementAt_Complete_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            completed(690)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            next(460, 72),
            completed(460)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 460)
            ])
    }
    
    
    func testElementAt_Complete_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            completed(320)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            error(320, RxError.ArgumentOutOfRange)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testElementAt_Error_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            next(460, 72),
            completed(460)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 460)
            ])
    }
    
    func testElementAt_Error_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            error(310, testError)
            ])
        
        let res = scheduler.start {
            xs.elementAt(10)
        }
        
        XCTAssertEqual(res.events, [
            error(310, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 310)
            ])
    }
    
    func testElementAt_Dispose_Before() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start(250) {
            xs.elementAt(3)
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testElementAt_Dispose_After() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            next(410, 15),
            next(415, 16),
            next(460, 72),
            next(510, 76),
            next(560, 32),
            next(570, -100),
            next(580, -3),
            next(590, 5),
            next(630, 10),
            error(690, testError)
            ])
        
        let res = scheduler.start(400) {
            xs.elementAt(3)
        }
        
        XCTAssertEqual(res.events, [
            next(280, 1),
            completed(280)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 280)
            ])
    }
    
    func testElementAt_First() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 6),
            next(150, 4),
            next(210, 9),
            next(230, 13),
            next(270, 7),
            next(280, 1),
            next(300, -1),
            next(310, 3),
            next(340, 8),
            next(370, 11),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.elementAt(0)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 9),
            completed(210)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }
}


// MARK: single
extension ObservableStandardSequenceOperatorsTest {
    
    func testSingle_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.single()
        }
        
        XCTAssertEqual(res.events, [
            error(250, RxError.NoElements)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSingle_One() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.single()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSingle_Many() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.single()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            error(220, RxError.MoreThanOneElement)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220)
            ])
    }
    
    func testSingle_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError)
            ])
        
        let res = scheduler.start {
            xs.single()
        }
        
        XCTAssertEqual(res.events, [
            error(210, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testSingle_DecrementCountsFirst() {
        let k = BehaviorSubject(value: false)

        _ = k.single { _ in true }.subscribeNext { n in
            k.on(.Next(!n))
        }
    }
    
    func testSinglePredicate_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.single { e in
                return e % 2 == 1
            }
        }
        
        XCTAssertEqual(res.events, [
            error(250, RxError.NoElements)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSinglePredicate_One() {
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
            xs.single() { e in
                return e == 4
            }
        }
        
        XCTAssertEqual(res.events, [
            next(230, 4),
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testSinglePredicate_Many() {
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
            xs.single() { e in
                return (e % 2) == 1
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, 3),
            error(240, RxError.MoreThanOneElement)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 240)
            ])
    }
    
    func testSinglePredicate_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError)
            ])
        
        let res = scheduler.start {
            xs.single() { e in
                return e % 2 == 1
            }
        }
        
        XCTAssertEqual(res.events, [
            error(210, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testSinglePredicate_Throws() {
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
            xs.single() { (e: Int) -> Bool in
                guard e < 4 else {
                    throw testError
                }
                return false
            }
        }
        
        XCTAssertEqual(res.events, [
            error(230, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testSinglePredicate_DecrementCountsFirst() {
        let k = BehaviorSubject(value: false)

        _ = k.single { _ in true }.subscribeNext { n in
            k.on(.Next(!n))
        }

    }
    
}
