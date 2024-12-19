//
//  Observable+FilterTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

#if os(Linux)
import Glibc
#endif

class ObservableFilterTest : RxTest {
}

func isPrime(_ i: Int) -> Bool {
    if i <= 1 {
        return false
    }
    
    let max = Int(sqrt(Double(i)))
    if max <= 1 {
        return true
    }
    
    for j in 2 ... max where i % j == 0 {
        return false
    }
    
    return true
}

extension ObservableFilterTest {
    func test_filterComplete() {
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
            return xs.filter { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
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
    
    func test_filterTrue() {
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
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.filter { _ -> Bool in
                invoked += 1
                return true
            }
        }
        
        XCTAssertEqual(res.events, [
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
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
        ])
        
        XCTAssertEqual(9, invoked)
    }
    
    func test_filterFalse() {
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
        
        let res = scheduler.start { () -> Observable<Int> in
            return xs.filter { _ -> Bool in
                invoked += 1
                return false
            }
        }
        
        XCTAssertEqual(res.events, [
            .completed(600)
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
            return xs.filter { (num: Int) -> Bool in
                invoked += 1
                return isPrime(num)
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
    
    func testFilterWithObject_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 10)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1)
        ])
        
        let res = scheduler.start {
            xs.filter(with: testObject) { object, element in
                object.value > element
            }
        }
        
        let correctMessages: [Recorded<Event<(TestObject, Int)>>] = []
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testFilterWithObject_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 10)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.filter(with: testObject) { object, element in
                object.value > element
            }
        }
        
        let correctMessages = [
            Recorded.completed(300, (TestObject, Int).self)
        ]
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testFilterWithObject_SomeElementsPass() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 2)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 1),
            .next(220, 2),
            .next(230, 3),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.filter(with: testObject) { object, element in
                object.value > element
            }
        }
        
        let correctMessages = Recorded.events(
            .next(210, (testObject, 1)),
            .completed(300)
        )
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events.map { ($0.time, $0.value.element?.1) }, correctMessages.map { ($0.time, $0.value.element?.1) })
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testFilterWithObject_AllElementsPass() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 10)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 1),
            .next(220, 2),
            .next(230, 3),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.filter(with: testObject) { object, element in
                object.value > element
            }
        }
        
        let correctMessages = Recorded.events(
            .next(210, (testObject, 1)),
            .next(220, (testObject, 2)),
            .next(230, (testObject, 3)),
            .completed(300)
        )
        
        XCTAssertEqual(res.events.map { ($0.time, $0.value.element?.1) }, correctMessages.map { ($0.time, $0.value.element?.1) })
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 300)])
    }
    
    func testFilterWithObject_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 5)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .error(220, testError)
        ])
        
        let res = scheduler.start {
            xs.filter(with: testObject) { object, element in
                object.value > element
            }
        }
        
        let correctMessages = Recorded.events(
            .next(210, (testObject, 2)),
            .error(220, testError)
        )
        
        XCTAssertEqual(res.events.map { ($0.time, $0.value.element?.1) }, correctMessages.map { ($0.time, $0.value.element?.1) })
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 220)])
    }
    
    func testFilterWithObject_ThrowsInPredicate() {
        let scheduler = TestScheduler(initialClock: 0)
        let testObject = TestObject(value: 5)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .completed(300)
        ])
        
        let res = scheduler.start {
            xs.filter(with: testObject) { object, element in
                if element > 2 { throw testError }
                return object.value > element
            }
        }
        
        let correctMessages = Recorded.events(
            .next(210, (testObject, 2)),
            .error(220, testError)
        )
        
        XCTAssertEqual(res.events.map { ($0.time, $0.value.element?.1) }, correctMessages.map { ($0.time, $0.value.element?.1) })
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 220)])
    }
    
#if TRACE_RESOURCES
    func testFilterReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).filter { _ in true }.subscribe()
    }
    
    func testFilter1ReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).filter { _ in true }.subscribe()
    }
    
    func testFilter2ReleasesResourcesOnError() {
        _ = Observable<Int>.just(1).filter { _ -> Bool in throw testError }.subscribe()
    }
#endif
}

extension ObservableFilterTest {
    func testIgnoreElements_DoesNotSendValues() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(210, 1),
            .next(220, 2),
            .completed(230)
        ])
        
        let res = scheduler.start {
            xs.ignoreElements()
        }
        
        XCTAssertEqual(res.events, [
            .completed(230)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
        ])
    }
    
#if TRACE_RESOURCES
    func testIgnoreElementsReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).ignoreElements().subscribe()
    }
    
    func testIgnoreElementsReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).ignoreElements().subscribe()
    }
#endif
}

private class TestObject: AnyObject {
    let value: Int
    init(value: Int) {
        self.value = value
    }
}
