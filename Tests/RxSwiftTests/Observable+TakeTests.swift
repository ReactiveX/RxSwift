//
//  Observable+TakeTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableTakeTest : RxTest {
}

extension ObservableTakeTest {
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
        
        let res = scheduler.start(disposed: 250) {
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
        
        let res = scheduler.start(disposed: 400) {
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
        
        _ = k.take(1).subscribe(onNext: { n in
            k.on(.next(!n))
        })
    }

    #if TRACE_RESOURCES
        func testTakeReleasesResourcesOnComplete() {
            _ = Observable<Int>.of(1, 2).take(1).subscribe()
        }

        func testTakeReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).take(1).subscribe()
        }
    #endif
}


extension ObservableTakeTest {

    func testTake_TakeZero() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230)
        ])

        let res = scheduler.start {
            xs.take(0, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            completed(201)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 201)
            ])
    }

    func testTake_Some() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(240)
            ])

        let res = scheduler.start {
            xs.take(25, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            completed(225)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 225)
            ])
    }

    func testTake_TakeLate() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230),
            ])

        let res = scheduler.start {
            xs.take(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            completed(230)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testTake_TakeError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(0, 0),
            error(210, testError)
            ])

        let res = scheduler.start {
            xs.take(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            error(210, testError),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testTake_TakeNever() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(0, 0),
            ])

        let res = scheduler.start {
            xs.take(50, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testTake_TakeTwice1() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            completed(270)
            ])

        let res = scheduler.start {
            xs.take(55, scheduler: scheduler).take(35, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(235)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 235)
            ])
    }

    func testTake_TakeDefault() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(240, 4),
            next(250, 5),
            next(260, 6),
            completed(270)
            ])

        let res = scheduler.start {
            xs.take(35, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            completed(235)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 235)
            ])
    }


    #if TRACE_RESOURCES
        func testTakeTimeReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).take(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testTakeTimeReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).take(35, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}
