//
//  Observable+DynamicMemberLookupTests.swift
//  Tests
//
//  Created by Yuri Ferretti on 14/09/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableDynamicMemberLookupTest : RxTest {
}

extension ObservableDynamicMemberLookupTest {
    func testDynamicMap_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, "test"),
            ])
        
        let res = scheduler.start { xs.count }
        
        let correctMessages: [Recorded<Event<Int>>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDynamicMap_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, "test"),
            .completed(300)
            ])
        
        let res = scheduler.start { xs.count }
        
        let correctMessages = [
            Recorded.completed(300, Int.self)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDynamicMap_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, "test"),
            .next(210, "testa"),
            .next(220, "testab"),
            .next(230, "testabc"),
            .next(240, "testabcd"),
            .completed(300)
            ])
        
        let res = scheduler.start { xs.count }
        
        let correctMessages = Recorded.events(
            .next(210, 5),
            .next(220, 6),
            .next(230, 7),
            .next(240, 8),
            .completed(300)
        )
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDynamicMap_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, "test"),
            .next(210, "testa"),
            .next(220, "testab"),
            .next(230, "testabc"),
            .next(240, "testabcd"),
            .error(300, testError)
            ])
        
        let res = scheduler.start { xs.count }
        
        let correctMessages = Recorded.events(
            .next(210, 5),
            .next(220, 6),
            .next(230, 7),
            .next(240, 8),
            .error(300, testError)
        )
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDynamicMap_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, "test"),
            .next(210, "testa"),
            .next(220, "testab"),
            .next(230, "testabc"),
            .next(240, "testabcd"),
            .error(300, testError)
            ])
        
        let res = scheduler.start(disposed: 290) { xs.count }
        
        let correctMessages = Recorded.events(
            .next(210, 5),
            .next(220, 6),
            .next(230, 7),
            .next(240, 8)
        )
        
        let correctSubscriptions = [
            Subscription(200, 290)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    #if TRACE_RESOURCES
        func testDynamicMapReleasesResourcesOnComplete() {
            _ = Observable<String>.just("test").count.subscribe()
        }

        func testDynamicMap1ReleasesResourcesOnError() {
            _ = Observable<String>.error(testError).count.subscribe()
        }
    #endif
}

// MARK: map compose
extension ObservableDynamicMemberLookupTest {
    
    private struct TestData {
        let string: String
    }
    
    func testDynamicMapCompose_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, TestData(string: "test")),
            ])

        let res = scheduler.start { xs.string.count }

        let correctMessages: [Recorded<Event<Int>>] = [
        ]

        let correctSubscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDynamicMapCompose_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, TestData(string: "test")),
            .completed(300)
            ])

        let res = scheduler.start { xs.string.count }

        let correctMessages = [
            Recorded.completed(300, Int.self)
        ]

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDynamicMapCompose_Range() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, TestData(string: "test")),
            .next(210, TestData(string: "testa")),
            .next(220, TestData(string: "testab")),
            .next(230, TestData(string: "testabc")),
            .next(240, TestData(string: "testabcd")),
            .completed(300)
            ])

        let res = scheduler.start { xs.string.count }

        let correctMessages = Recorded.events(
            .next(210, 5),
            .next(220, 6),
            .next(230, 7),
            .next(240, 8),
            .completed(300)
        )

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDynamicMapCompose_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, TestData(string: "test")),
            .next(210, TestData(string: "testa")),
            .next(220, TestData(string: "testab")),
            .next(230, TestData(string: "testabc")),
            .next(240, TestData(string: "testabcd")),
            .error(300, testError)
            ])

        let res = scheduler.start { xs.string.count }

        let correctMessages = Recorded.events(
            .next(210, 5),
            .next(220, 6),
            .next(230, 7),
            .next(240, 8),
            .error(300, testError)
        )

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDynamicMapCompose_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, TestData(string: "test")),
            .next(210, TestData(string: "testa")),
            .next(220, TestData(string: "testab")),
            .next(230, TestData(string: "testabc")),
            .next(240, TestData(string: "testabcd")),
            .error(300, testError)
            ])

        let res = scheduler.start(disposed: 290) { xs.string.count }

        let correctMessages = Recorded.events(
            .next(210, 5),
            .next(220, 6),
            .next(230, 7),
            .next(240, 8)
        )

        let correctSubscriptions = [
            Subscription(200, 290)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}

