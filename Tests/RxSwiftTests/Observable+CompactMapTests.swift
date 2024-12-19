//
//  Observable+CompactMapTests.swift
//  Tests
//
//  Created by Michael Long on 05/10/19.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

#if os(Linux)
import Glibc
#endif

class ObservableCompactMapTest : RxTest {
}

extension ObservableCompactMapTest {
    
    func test_compactMapNilFromClosure() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600),
            .next(610, 12),
            .error(620, testError),
            .completed(630)
        ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.compactMap { num in
                invoked += 1
                return isPrime(num) ? num : nil
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(230, 3),
            .next(340, 5),
            .next(390, 7),
            .next(580, 11),
            .completed(600)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
        ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_compactMapNilFromElement() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs: TestableObservable<Int?> = scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, nil),
            .next(340, 5),
            .completed(400),
            .next(410, 7),
            .error(420, testError),
            .completed(430)
        ])
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.compactMap { num in
                invoked += 1
                return num
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(230, 3),
            .next(340, 5),
            .completed(400),
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
        ])
        
        XCTAssertEqual(3, invoked)
    }
    
    func test_compactMapDisposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var invoked = 0
        
        let xs = scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600)
        ])
        
        let res = scheduler.start(disposed: 400) { () -> Observable<Int> in
            return xs.compactMap { num in
                invoked += 1
                return isPrime(num) ? num : nil
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(230, 3),
            .next(340, 5),
            .next(390, 7)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
        ])
        
        XCTAssertEqual(5, invoked)
    }
    
    func testCompactMapWithObject_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 10)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1)
        ])
        
        let res = scheduler.start {
            xs.compactMap(with: testObject) { object, element in
                return (object.value > element) ? element * 2 : nil
            }
        }
        
        let correctMessages: [Recorded<Event<Int>>] = []
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testCompactMapWithObject_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 10)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.compactMap(with: testObject) { object, element in
                return (object.value > element) ? element * 2 : nil
            }
        }
        
        let correctMessages = [
            Recorded.completed(300, Int.self)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testCompactMapWithObject_SomeElementsPass() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 3)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 1),
            .next(220, 2),
            .next(230, 3),
            .next(240, 4),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.compactMap(with: testObject) { object, element in
                return (object.value > element) ? element * 2 : nil
            }
        }
        
        let correctMessages = Recorded.events(
            .next(210, 1 * 2),
            .next(220, 2 * 2),
            .completed(300)
        )
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 300)])
    }
    
    func testCompactMapWithObject_AllElementsFiltered() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 1)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.compactMap(with: testObject) { object, element in
                return (object.value > element) ? element * 2 : nil
            }
        }
        
        let correctMessages = Recorded.events(
            .completed(300)
        )
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 300)])
    }
    
    func testCompactMapWithObject_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 3)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 1),
            .next(220, 2),
            .error(230, testError)
        ])
        
        let res = scheduler.start {
            xs.compactMap(with: testObject) { object, element in
                return (object.value > element) ? element * 2 : nil
            }
        }
        
        let correctMessages = Recorded.events(
            .next(210, 1 * 2),
            .next(220, 2 * 2),
            .error(230, testError)
        )
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 230)])
    }
    
    func testCompactMapWithObject_ThrowsInTransform() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 5)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 1),
            .next(220, 2),
            .next(230, 3),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.compactMap(with: testObject) { object, element in
                if element > 2 { throw testError }
                return object.value + element
            }
        }
        
        let correctMessages = Recorded.events(
            .next(210, 5 + 1),
            .next(220, 5 + 2),
            .error(230, testError)
        )
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 230)])
    }
}

private class TestObject: AnyObject {
    let value: Int
    init(value: Int) {
        self.value = value
    }
}
