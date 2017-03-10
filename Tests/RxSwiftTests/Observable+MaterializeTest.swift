//
//  Observable+MaterializeTest.swift
//  Rx
//
//  Created by Jamie Pinkham on 3/10/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest


fileprivate func eventsEqual<T: Equatable>(lhs: Recorded<Event<Event<T>>>, rhs: Recorded<Event<Event<T>>>) -> Bool {
    if lhs.time == lhs.time {
        switch(lhs.value, lhs.value) {
        case let(.next(a), .next(b)): return a == b
        case (.completed, .completed): return true
        default: return false
        }
    } else {
        return false
    }
}


enum MaterializeError: Error {
    case anError
}

class ObservableMaterializeTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMaterialize() {
        let values = [0, 42, -7, 100, 1000, 1]
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Event<Int>.self)
        
        _ = Observable.from(values)
            .materialize()
            .subscribe(observer)
        
        scheduler.start()
        
        let correct = [
            next(0, Event.next(0)),
            next(0, Event.next(42)),
            next(0, Event.next(-7)),
            next(0, Event.next(100)),
            next(0, Event.next(1000)),
            next(0, Event.next(1)),
            next(0, Event.completed),
            completed(0)
        ]
        
        XCTAssertEqual(correct.count, observer.events.count)
        let equal = zip(observer.events, correct).reduce(false) { (bool, events) -> Bool in
            return eventsEqual(lhs: events.0, rhs: events.1)
        }
        XCTAssertTrue(equal)
    }
    
    func testDematerialize() {
        let values = [0, 42, -7, 100, 1000, 1]
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Int.self)
        
        _ = Observable.from(values)
            .materialize()
            .dematerialize()
            .subscribe(observer)
        
        scheduler.start()
        
        let correct = [
            next(0, 0),
            next(0, 42),
            next(0, -7),
            next(0, 100),
            next(0, 1000),
            next(0, 1),
            completed(0)
        ]
        
        XCTAssertEqual(observer.events, correct)
    }
    
    func testMaterializeError() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Event<Int>.self)
        
        _ = Observable.error(MaterializeError.anError)
            .startWith(42)
            .materialize()
            .subscribe(observer)
        
        scheduler.start()
        
        let correct = [
            next(0, Event.next(42)),
            next(0, Event.error(MaterializeError.anError)),
            completed(0)
        ]
        
        XCTAssertEqual(correct.count, observer.events.count)
        let equal = zip(observer.events, correct).reduce(false) { (bool, events) -> Bool in
            return eventsEqual(lhs: events.0, rhs: events.1)
        }
        XCTAssertTrue(equal)
        
    }
    
    func testDematerializeError() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Int.self)
        
        _ = Observable.error(MaterializeError.anError)
            .startWith(42)
            .materialize()
            .dematerialize()
            .subscribe(observer)
        
        scheduler.start()
        
        let correct = [
            next(0, 42),
            error(0, MaterializeError.anError)
        ]
        
        XCTAssertEqual(observer.events, correct)
    }
    
}
