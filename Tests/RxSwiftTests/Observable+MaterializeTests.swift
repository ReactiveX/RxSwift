//
//  Observable+MaterializeTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableMaterializeTest : RxTest {
}

extension ObservableMaterializeTest {
    func testMaterializeNever() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            return Observable<Int>.never().materialize()
        }
        XCTAssertEqual(res.events, [], materializedRecoredEventsComparison)
    }
    
    func testMaterializeEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .completed(201, Int.self),
            .completed(202, Int.self),
            ])
        let res = scheduler.start {
            return xs.materialize()
        }
        let expectedEvents = Recorded.events(
            .next(201, Event<Int>.completed),
            .completed(201)
        )
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 201)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    func testMaterializeEmits() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(250),
            .completed(251),
            ])
        let res = scheduler.start {
            return xs.materialize()
        }
        let expectedEvents = Recorded.events(
            .next(210, Event.next(2)),
            .next(250, Event.completed),
            .completed(250)
        )
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    func testMaterializeThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError),
            .error(251, testError),
            ])
        let res = scheduler.start {
            return xs.materialize()
        }
        let expectedEvents = Recorded.events(
            .next(250, Event<Int>.error(testError)),
            .completed(250)
        )
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    #if TRACE_RESOURCES
        func testMaterializeReleasesResourcesOnComplete1() {
            _ = Observable<Int>.just(1).materialize().subscribe()
        }
        
        func testMaterializeReleasesResourcesOnComplete2() {
            _ = Observable<Int>.empty().materialize().subscribe()
        }
        
        func testMaterializeReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).materialize().subscribe()
        }
    #endif
}

fileprivate func materializedRecoredEventsComparison<T: Equatable>(lhs: [Recorded<Event<Event<T>>>], rhs: [Recorded<Event<Event<T>>>]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }
    for (lhsElement, rhsElement) in zip(lhs, rhs) {
        guard lhsElement == rhsElement else {
            return false
        }
    }
    
    return true
}

fileprivate func == <T: Equatable>(lhs: Recorded<Event<Event<T>>>, rhs: Recorded<Event<Event<T>>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

fileprivate func == <T: Equatable>(lhs: Event<Event<T>>, rhs: Event<Event<T>>) -> Bool {
    switch (lhs, rhs) {
    case (.next(let lhsEvent), .next(let rhsEvent)):
        return lhsEvent == rhsEvent
    case (.completed, .completed): return true
    case (.error(let e1), .error(let e2)):
        #if os(Linux)
            return  "\(e1)" == "\(e2)"
        #else
            let error1 = e1 as NSError
            let error2 = e2 as NSError
            
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(e1)" == "\(e2)"
        #endif
    default:
        return false
    }
}
