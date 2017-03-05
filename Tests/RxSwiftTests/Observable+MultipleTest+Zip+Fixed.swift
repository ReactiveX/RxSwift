//
//  Observable+MultipleTest+Zip+Fixed.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/5/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

extension ObservableMultipleTest {
    func testZip_NeverEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let n = scheduler.createHotObservable([
            next(150, 1)
        ])

        let e = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
        ])

        let res = scheduler.start {
            Observable.zip(n, e) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])
    }

    func testZip_EmptyNever() {
        let scheduler = TestScheduler(initialClock: 0)

        let n = scheduler.createHotObservable([
            next(150, 1)
        ])

        let e = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
        ])

        let res = scheduler.start {
            Observable.zip(e, n) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])
    }

    func testZip_EmptyNonEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let e = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
        ])

        let o = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
        ])

        let res = scheduler.start {
            Observable.zip(e, o) { $0 + $1 }
        }
   
        let messages = [
            completed(215, Int.self)
        ]
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 215)
        ])
    }

    func testZip_NonEmptyEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let e = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
        ])

        let o = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
        ])

        let res = scheduler.start {
            Observable.zip(o, e) { $0 + $1 }
        }
   
        let messages = [
            completed(215, Int.self)
        ]
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(e.subscriptions, [
            Subscription(200, 210)
        ])

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 215)
        ])
    }

    func testZip_NeverNonEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let n = scheduler.createHotObservable([
            next(150, 1),
        ])

        let o = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
        ])

        let res = scheduler.start {
            Observable.zip(n, o) { $0 + $1 }
        }
   
        let messages: [Recorded<Event<Int>>] = []
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])
    }

    func testZip_NonEmptyNever() {
        let scheduler = TestScheduler(initialClock: 0)

        let n = scheduler.createHotObservable([
            next(150, 1),
        ])

        let o = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
        ])

        let res = scheduler.start {
            Observable.zip(o, n) { $0 + $1 }
        }
   
        let messages: [Recorded<Event<Int>>] = []
        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(n.subscriptions, [
            Subscription(200, 1000)
        ])
    }

    func testZip_NonEmptyNonEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(240)
        ])

        let res = scheduler.start {
            Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            next(220, 2 + 3),
            completed(240)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 230)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 240)
        ])
    }

    func testZip_EmptyError() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
        ])

        let res = scheduler.start {
            Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
        ])

        let res = scheduler.start {
            Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_NeverError() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
        ])

        let res = scheduler.start {
            Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorNever() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
        ])

        let res = scheduler.start {
            Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorError() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError1)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError2)
        ])

        let res = scheduler.start {
            Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            error(220, testError2, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_SomeError() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError1)
        ])

        let res = scheduler.start {
            Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            error(220, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_ErrorSome() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError1)
        ])

        let res = scheduler.start {
            Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            error(220, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_LeftCompletesFirst() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 4),
            completed(225)
        ])

        let res = scheduler.start {
            Observable.zip(o1, o2) { $0 + $1 }
        }
   
        let messages = [
            next(215, 2 + 4),
            completed(225)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 225)
        ])
    }

    func testZip_RightCompletesFirst() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 4),
            completed(225)
        ])

        let res = scheduler.start {
            Observable.zip(o2, o1) { $0 + $1 }
        }
   
        let messages = [
            next(215, 2 + 4),
            completed(225)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 225)
        ])
    }

    func testZip_LeftTriggersSelectorError() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(220)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 4),
        ])

        let res = scheduler.start {
            Observable.zip(o1, o2) { (_, _) throws -> Int in throw testError }
        }
   
        let messages = [
            error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }

    func testZip_RightTriggersSelectorError() {
        let scheduler = TestScheduler(initialClock: 0)

        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(220)
        ])

        let o2 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 4),
        ])

        let res = scheduler.start {
            Observable.zip(o2, o1) { (_, _) throws -> Int in throw testError }
        }
   
        let messages = [
            error(220, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(o2.subscriptions, [
            Subscription(200, 220)
        ])
    }





}

// MARK: zip
extension ObservableMultipleTest {
    #if TRACE_RESOURCES
        func testZipReleasesResourcesOnComplete1() {
            _ = Observable.zip(Observable.just(1), Observable.just(1), resultSelector: +).subscribe()
        }

        func testZipReleasesResourcesOnError1() {
            _ = Observable.zip(Observable.just(1), Observable<Int>.error(testError), resultSelector: +).subscribe()
        }

        func testZipReleasesResourcesOnComplete2() {
            _ = Observable.zip(Observable.just(1), Observable.just(1)).subscribe()
        }

        func testZipReleasesResourcesOnError2() {
            _ = Observable.zip(Observable.just(1), Observable<Int>.error(testError)).subscribe()
        }

    #endif
}
