//
//  Observable+SwitchTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableSwitchTest : RxTest {
}

extension ObservableSwitchTest {

    func testSwitch_Data() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
        ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
        ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(20, 302),
            .next(30, 303),
            .next(40, 304),
            .completed(150)
        ])
        
        let xSequence = Recorded.events(
            .next(300, ys1),
            .next(400, ys2),
            .next(500, ys3),
            .completed(600)
        )
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.switchLatest()
        }
        
        let correct = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 201),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .next(510, 301),
            .next(520, 302),
            .next(530, 303),
            .next(540, 304),
            .completed(650)
        )
        
        XCTAssertEqual(res.events, correct)
        
        let subscriptions = [
            Subscription(200, 600)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
        
        let ys1Subscriptions = [
            Subscription(300, 400)
        ]

        XCTAssertEqual(ys1.subscriptions, ys1Subscriptions)
        
        let y2Subscriptions = [
            Subscription(400, 450)
        ]
        
        XCTAssertEqual(ys2.subscriptions, y2Subscriptions)
        
        let y3Subscriptions = [
            Subscription(500, 650)
        ]

        XCTAssertEqual(ys3.subscriptions, y3Subscriptions)
    }
    
    func testSwitch_InnerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .error(50, testError)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(20, 302),
            .next(30, 303),
            .next(40, 304),
            .completed(150)
            ])
        
        let xSequence = Recorded.events(
            .next(300, ys1),
            .next(400, ys2),
            .next(500, ys3),
            .completed(600)
        )
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.switchLatest()
        }
        
        let correct = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 201),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .error(450, testError)
        )
        
        XCTAssertEqual(res.events, correct)
        
        let subscriptions = [
            Subscription(200, 450)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
        
        let ys1Subscriptions = [
            Subscription(300, 400)
        ]
        
        XCTAssertEqual(ys1.subscriptions, ys1Subscriptions)
        
        let y2Subscriptions = [
            Subscription(400, 450)
        ]
        
        XCTAssertEqual(ys2.subscriptions, y2Subscriptions)
        
        let y3Subscriptions: [Subscription] = [
        ]
        
        XCTAssertEqual(ys3.subscriptions, y3Subscriptions)
    }
    
    func testSwitch_OuterThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
            ])
        
        let xSequence = Recorded.events(
            .next(300, ys1),
            .next(400, ys2),
            .error(500, testError)
        )
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.switchLatest()
        }
        
        let correct = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 201),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .error(500, testError)
        )
        
        XCTAssertEqual(res.events, correct)
        
        let subscriptions = [
            Subscription(200, 500)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
        
        let ys1Subscriptions = [
            Subscription(300, 400)
        ]
        
        XCTAssertEqual(ys1.subscriptions, ys1Subscriptions)
        
        let y2Subscriptions = [
            Subscription(400, 450)
        ]
        
        XCTAssertEqual(ys2.subscriptions, y2Subscriptions)
    }

    #if TRACE_RESOURCES
        func testSwitchReleasesResourcesOnComplete() {
            _ = Observable.of(Observable<Int>.just(1)).switchLatest().subscribe()
        }

        func testSwitch1ReleasesResourcesOnError() {
            _ = Observable.of(Observable<Int>.error(testError)).switchLatest().subscribe()
        }

        func testSwitch2ReleasesResourcesOnError() {
            _ = Observable<Observable<Int>>.error(testError).switchLatest().subscribe()
        }
    #endif
}

extension ObservableSwitchTest {

    func testFlatMapLatest_Data() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
        ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
        ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(20, 302),
            .next(30, 303),
            .next(40, 304),
            .completed(150)
        ])

        let observables = [ys1, ys2, ys3]
        
        let xSequence = Recorded.events(
            .next(300, 0),
            .next(400, 1),
            .next(500, 2),
            .completed(600)
        )
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.flatMapLatest { observables[$0] }
        }
        
        let correct = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 201),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .next(510, 301),
            .next(520, 302),
            .next(530, 303),
            .next(540, 304),
            .completed(650)
        )
        
        XCTAssertEqual(res.events, correct)
        
        let subscriptions = [
            Subscription(200, 600)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
        
        let ys1Subscriptions = [
            Subscription(300, 400)
        ]

        XCTAssertEqual(ys1.subscriptions, ys1Subscriptions)
        
        let y2Subscriptions = [
            Subscription(400, 450)
        ]
        
        XCTAssertEqual(ys2.subscriptions, y2Subscriptions)
        
        let y3Subscriptions = [
            Subscription(500, 650)
        ]

        XCTAssertEqual(ys3.subscriptions, y3Subscriptions)
    }
    
    func testFlatMapLatest_InnerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .error(50, testError)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(20, 302),
            .next(30, 303),
            .next(40, 304),
            .completed(150)
            ])

        let observables = [ys1, ys2, ys3]
        
        let xSequence = Recorded.events(
            .next(300, 0),
            .next(400, 1),
            .next(500, 2),
            .completed(600)
        )
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.flatMapLatest { observables[$0] }
        }
        
        let correct = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 201),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .error(450, testError)
        )
        
        XCTAssertEqual(res.events, correct)
        
        let subscriptions = [
            Subscription(200, 450)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
        
        let ys1Subscriptions = [
            Subscription(300, 400)
        ]
        
        XCTAssertEqual(ys1.subscriptions, ys1Subscriptions)
        
        let y2Subscriptions = [
            Subscription(400, 450)
        ]
        
        XCTAssertEqual(ys2.subscriptions, y2Subscriptions)
        
        let y3Subscriptions: [Subscription] = [
        ]
        
        XCTAssertEqual(ys3.subscriptions, y3Subscriptions)
    }
    
    func testFlatMapLatest_OuterThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
            ])

        let observables = [ys1, ys2]
        
        let xSequence = Recorded.events(
            .next(300, 0),
            .next(400, 1),
            .error(500, testError)
        )
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.flatMapLatest { observables[$0] }
        }
        
        let correct = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 201),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .error(500, testError)
        )
        
        XCTAssertEqual(res.events, correct)
        
        let subscriptions = [
            Subscription(200, 500)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
        
        let ys1Subscriptions = [
            Subscription(300, 400)
        ]
        
        XCTAssertEqual(ys1.subscriptions, ys1Subscriptions)
        
        let y2Subscriptions = [
            Subscription(400, 450)
        ]
        
        XCTAssertEqual(ys2.subscriptions, y2Subscriptions)
    }

    func testFlatMapLatest_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])

        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
            ])

        let observables = [ys1, ys2]

        let xSequence = Recorded.events(
            .next(300, 0),
            .next(400, 1)
        )

        let xs = scheduler.createHotObservable(xSequence)

        let res = scheduler.start {
            xs.flatMapLatest { x throws -> TestableObservable<Int> in
                if x < 1 {
                    return observables[x]
                }
                else {
                    throw testError
                }
            }
        }

        let correct = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .error(400, testError)
        )

        XCTAssertEqual(res.events, correct)

        let subscriptions = [
            Subscription(200, 400)
        ]

        XCTAssertEqual(xs.subscriptions, subscriptions)

        let ys1Subscriptions = [
            Subscription(300, 400)
        ]

        XCTAssertEqual(ys1.subscriptions, ys1Subscriptions)

        XCTAssertEqual(ys2.subscriptions, [])
    }

    #if TRACE_RESOURCES
        func testFlatMapLatest1ReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).flatMapLatest { _ in Observable.just(1).concat(Observable.timer(20, scheduler: testScheduler)) }.subscribe()

            testScheduler.start()
        }

        func testFlatMapLatest2ReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.of(1, 2).concat(Observable.timer(20, scheduler: testScheduler)).flatMapLatest { _ in Observable.just(1) }.subscribe()
            testScheduler.start()
        }

        func testFlatMapLatest1ReleasesResourcesOnError() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).flatMapLatest { _ in
                Observable.just(1)
                    .concat(Observable.timer(20, scheduler: testScheduler))
                    .timeout(10, scheduler: testScheduler)
            }.subscribe()

            testScheduler.start()
        }

        func testFlatMapLatest2ReleasesResourcesOnError() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.of(1, 2).concat(Observable.timer(20, scheduler: testScheduler))
                .timeout(10, scheduler: testScheduler)
                .flatMapLatest { _ in Observable.just(1) }.subscribe()
            testScheduler.start()
        }
    #endif
}
