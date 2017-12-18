//
//  Observable+OfTypeTests.swift
//  Tests
//
//  Created by Nate Kim on 18/12/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

#if os(Linux)
    import Glibc
#endif

class ObservableOfTypeTest : RxTest {
}

extension ObservableOfTypeTest {
    func test_ofTypeComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(110, NSNumber(value: 1)),
            next(180, NSDecimalNumber(string: "2") as NSNumber),
            next(230, NSNumber(value: 3)),
            next(270, NSNumber(value: 4)),
            next(340, NSDecimalNumber(string: "5") as NSNumber),
            next(380, NSDecimalNumber(string: "6") as NSNumber),
            completed(400),
            next(410, NSDecimalNumber(string: "7") as NSNumber),
            next(420, NSNumber(value: 8)),
            error(430, testError),
            completed(440)
        ])
        
        let res = scheduler.start { () -> Observable<NSDecimalNumber> in
            return xs.ofType(NSDecimalNumber.self)
        }
        
        XCTAssertEqual(res.events, [
            next(340, NSDecimalNumber(string: "5")),
            next(380, NSDecimalNumber(string: "6")),
            completed(400)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(TestScheduler.Defaults.subscribed, 400)
        ])
    }
    
    func test_ofTypeDowncastComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<NSNumber> = scheduler.createHotObservable([
            next(110, NSNumber(value: 1)),
            next(180, NSDecimalNumber(string: "2") as NSNumber),
            next(230, NSNumber(value: 3)),
            next(270, NSNumber(value: 4)),
            next(340, NSDecimalNumber(string: "5") as NSNumber),
            next(380, NSDecimalNumber(string: "6") as NSNumber),
            completed(400),
            next(410, NSDecimalNumber(string: "7") as NSNumber),
            next(420, NSNumber(value: 8)),
            error(430, testError),
            completed(440)
        ])
        
        let res = scheduler.start { () -> Observable<NSNumber> in
            return xs.ofType(NSNumber.self)
        }
        
        XCTAssertEqual(res.events, [
            next(230, NSNumber(value: 3)),
            next(270, NSNumber(value: 4)),
            next(340, NSDecimalNumber(string: "5")),
            next(380, NSDecimalNumber(string: "6")),
            completed(400)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(TestScheduler.Defaults.subscribed, 400)
        ])
    }
    
    func test_ofTypeNoInstanceComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<NSNumber> = scheduler.createHotObservable([
            next(110, NSNumber(value: 1)),
            next(180, NSDecimalNumber(string: "2") as NSNumber),
            next(230, NSNumber(value: 3)),
            next(270, NSNumber(value: 4)),
            next(340, NSDecimalNumber(string: "5") as NSNumber),
            next(380, NSDecimalNumber(string: "6") as NSNumber),
            completed(400),
            next(410, NSDecimalNumber(string: "7") as NSNumber),
            next(420, NSNumber(value: 8)),
            error(430, testError),
            completed(440)
        ])
        
        let res = scheduler.start { () -> Observable<String> in
            return xs.ofType(String.self)
        }
        
        XCTAssertEqual(res.events, [completed(400)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(TestScheduler.Defaults.subscribed, 400)
        ])
    }
    
    func test_ofTypeDisposed() {
        let scheduler = TestScheduler(initialClock: 0)

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
            completed(500)
        ])

        let res = scheduler.start(disposed: 400) { () -> Observable<Int> in
            return xs.ofType(Int.self)
        }

        XCTAssertEqual(res.events, [
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(TestScheduler.Defaults.subscribed, 400)
        ])
    }
    
    #if TRACE_RESOURCES
    func testOfTypeReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).ofType(Int.self).subscribe()
    }
    
    func testOfTypeReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).ofType(Int.self).subscribe()
    }
    #endif
}
