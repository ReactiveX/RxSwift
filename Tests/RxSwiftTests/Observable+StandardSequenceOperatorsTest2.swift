//
//  Observable+StandardSequenceOperatorsTest2.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/31/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
#if os(Linux)
    import Glibc
#endif

import struct Foundation.CharacterSet

extension ObservableStandardSequenceOperatorsTest
{
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

    #if TRACE_RESOURCES
        func testFlatMapWithIndexReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).flatMapWithIndex { _ in Observable.just(1) }.subscribe()
        }

        func testFlatMapWithIndex1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).flatMapWithIndex { _ in Observable.just(1) }.subscribe()
        }

        func testFlatMapWithIndex2ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).flatMapWithIndex { _ -> Observable<Int> in throw testError }.subscribe()
        }

        func testFlatMapWithIndex3ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).flatMapWithIndex { _ -> Observable<Int> in Observable.error(testError) }.subscribe()
        }
    #endif
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
        _ = k.takeLast(1).subscribe(onNext: { n in
            elements.append(n)
            k.on(.next(!n))
        })

        k.on(.completed)

        XCTAssertEqual(elements, [false])
    }

    #if TRACE_RESOURCES
        func testTakeLastReleasesResourcesOnComplete() {
        _ = Observable<Int>.of(1, 2).takeLast(1).subscribe()
        }

        func testTakeLastReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).takeLast(1).subscribe()
        }
    #endif
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

    #if TRACE_RESOURCES
        func testSkipReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).skip(1).subscribe()
        }

        func testSkipReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).skip(1).subscribe()
        }
    #endif
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

    #if TRACE_RESOURCES
        func testSkipWhileReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).skipWhile { _ in true }.subscribe()
        }

        func testSkipWhileReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).skipWhile { _ in true }.subscribe()
        }

        func testSkipWhileWithIndexReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).skipWhileWithIndex { _ in true }.subscribe()
        }

        func testSkipWhileWithIndexReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).skipWhileWithIndex { _ in true }.subscribe()
        }
    #endif
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
            error(320, RxError.argumentOutOfRange)
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

    #if TRACE_RESOURCES
        func testElementAtReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).elementAt(0).subscribe()
        }

        func testElementAtReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).elementAt(1).subscribe()
        }
    #endif
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
            error(250, RxError.noElements)
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
            error(220, RxError.moreThanOneElement)
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

    #if !DEBUG
    func testSingle_DecrementCountsFirst() {
        let k = BehaviorSubject(value: false)

        _ = k.single { _ in true }.subscribe(onNext: { n in
            k.on(.next(!n))
        })
    }
    #endif
    
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
            error(250, RxError.noElements)
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
            error(240, RxError.moreThanOneElement)
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

    #if !DEBUG
    func testSinglePredicate_DecrementCountsFirst() {
        let k = BehaviorSubject(value: false)

        _ = k.single { _ in true }.subscribe(onNext: { n in
            k.on(.next(!n))
        })
    }
    #endif

    #if TRACE_RESOURCES
        func testSingleReleasesResourcesOnComplete() {
        _ = Observable<Int>.just(1).single().subscribe()
        }

        func testSinleReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).single().subscribe()
        }
    #endif
}

// groupBy

extension ObservableSingleTest {
    func testGroupBy_TwoGroup() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<Int, Int>> = xs.groupBy { x in x % 2 }
            let mappedWithIndex = group.mapWithIndex { (go: GroupedObservable<Int, Int>, i: Int) -> Observable<String> in
                return go.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "1 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "0 5"),
            next(350, "1 6"),
            next(370, "0 7"),
            next(420, "1 8"),
            next(470, "0 9"),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testGroupBy_OuterComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                return x.lowercased().trimWhitespace()
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz"),
            next(360, "qux"),
            completed(570)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
        
        XCTAssertEqual(keyInvoked, 12)
    }
    
    func testGroupBy_OuterError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            error(570, testError),
            completed(600),
            error(650, testError)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                return x.lowercased().trimWhitespace()
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz"),
            next(360, "qux"),
            error(570, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
        
        XCTAssertEqual(keyInvoked, 12)
    }

    
    func testGroupBy_OuterDispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        let res = scheduler.start(355) { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                return x.lowercased().trimWhitespace()
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz")
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 355)
            ])
        
        XCTAssertEqual(keyInvoked, 5)
    }
    
    func testGroupBy_OuterKeySelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var keyInvoked = 0
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let group: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }

                if keyInvoked == 10 {
                    throw testError
                }
                return x.lowercased().trimWhitespace()
            }
            return group.map { (go: GroupedObservable<String, String>) -> String in
                return go.key
            }
        }
        
        XCTAssertEqual(res.events, [
            next(220, "foo"),
            next(270, "bar"),
            next(350, "baz"),
            next(360, "qux"),
            error(480, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 480)
            ])
        
        XCTAssertEqual(keyInvoked, 10)
    }
    
    func testGroupBy_InnerComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])

        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()

        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = scheduler.scheduleRelative((), dueTime: 100, action: { _ in
                    group.subscribe(result)
                })
            })
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
            
        }
        
        scheduler.start()

        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)])

        XCTAssertEqual(results["bar"]!.events, [
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])

        XCTAssertEqual(results["baz"]!.events, [
            next(480, "baz  "),
            next(510, " bAZ "),
            completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }
    
    func testGroupBy_InnerCompleteAll() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                innerSubscriptions[group.key] = group.subscribe(result)
            })
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)])

        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   "),
            next(480, "baz  "),
            next(510, " bAZ "),
            completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux "),
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            error(570, testError),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = scheduler.scheduleRelative((), dueTime: 100, action: { _ in
                     group.subscribe(result)
                })
            })
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(470, "FOO "),
            next(530, "    fOo    "),
            error(570, testError)])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(390, "   bar"),
            next(420, " BAR  "),
            error(570, testError)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(480, "baz  "),
            next(510, " bAZ "),
            error(570, testError)])
        
        XCTAssertEqual(results["qux"]!.events, [
            error(570, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }

    func testGroupBy_InnerDispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                innerSubscriptions[group.key] = group.subscribe(result)
            })
        }
        
        scheduler.scheduleAt(400) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar")])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   ")])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux ")])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testGroupBy_InnerKeyThrow() {
        let scheduler = TestScheduler(initialClock: 0)

        var keyInvoked = 0

        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                keyInvoked += 1
                if x == "error" { throw testError }
                if keyInvoked == 6 {
                    throw testError
                }
                return x.lowercased().trimWhitespace()
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                let result: TestableObserver<String> = scheduler.createObserver(String.self)
                inners[group.key] = group
                results[group.key] = result
                
                innerSubscriptions[group.key] = group.subscribe(result)
            })
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.count, 3)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            error(360, testError)])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            error(360, testError)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   "),
            error(360, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 360)
            ])
    }
    
    func testGroupBy_OuterIndependence() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        let outerResults: TestableObserver<String> = scheduler.createObserver(String.self)
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        outerResults.onNext(group.key)
                        
                        let result: TestableObserver<String> = scheduler.createObserver(String.self)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = group.subscribe(result)
                    },
                    onError: { (e) -> Void in
                        outerResults.onError(e)
                    },
                    onCompleted: {
                        outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }

        scheduler.scheduleAt(320) {
            outerSubscription?.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 2)
        
        XCTAssertEqual(outerResults.events, [
            next(220, "foo"),
            next(270, "bar")])
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)
            ])
    }
    
    func testGroupBy_InnerIndependence() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        let outerResults: TestableObserver<String> = scheduler.createObserver(String.self)
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = outer
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        outerResults.onNext(group.key)
                        
                        let result: TestableObserver<String> = scheduler.createObserver(String.self)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = group.subscribe(result)
                    },
                    onError: { (e) -> Void in
                        outerResults.onError(e)
                    },
                    onCompleted: {
                        outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.scheduleAt(320) {
            innerSubscriptions["foo"]!.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  "),
            next(390, "   bar"),
            next(420, " BAR  "),
            completed(570)])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   "),
            next(480, "baz  "),
            next(510, " bAZ "),
            completed(570)])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux "),
            completed(570)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerMultipleIndependence() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, "abc"),
            next(110, "zoo"),
            next(130, "oof"),
            next(220, "  foo"),
            next(240, " FoO "),
            next(270, "baR  "),
            next(310, "foO "),
            next(350, " Baz   "),
            next(360, "  qux "),
            next(390, "   bar"),
            next(420, " BAR  "),
            next(470, "FOO "),
            next(480, "baz  "),
            next(510, " bAZ "),
            next(530, "    fOo    "),
            completed(570),
            next(580, "error"),
            completed(600),
            error(650, testError)
            ])
        
        var outerSubscription: Disposable?
        var inners = Dictionary<String, GroupedObservable<String, String>>()
        var innerSubscriptions = Dictionary<String, Disposable>()
        var results = Dictionary<String, TestableObserver<String>>()
        let outerResults: TestableObserver<String> = scheduler.createObserver(String.self)
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                if x == "error" { throw testError }
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = outer
                .subscribe(
                    onNext: { (group: GroupedObservable<String, String>) -> Void in
                        outerResults.onNext(group.key)
                        
                        let result: TestableObserver<String> = scheduler.createObserver(String.self)
                        inners[group.key] = group
                        results[group.key] = result
                        innerSubscriptions[group.key] = group.subscribe(result)
                    },
                    onError: { (e) -> Void in
                        outerResults.onError(e)
                    },
                    onCompleted: {
                        outerResults.onCompleted()
                    },
                    onDisposed: nil)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            for (_, disposable) in innerSubscriptions {
                disposable.dispose()
            }
        }
        
        scheduler.scheduleAt(320) {
            innerSubscriptions["foo"]!.dispose()
        }
        
        scheduler.scheduleAt(280) {
            innerSubscriptions["bar"]!.dispose()
        }

        scheduler.scheduleAt(355) {
            innerSubscriptions["baz"]!.dispose()
        }

        scheduler.scheduleAt(400) { () -> Void in
            innerSubscriptions["qux"]!.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(inners.keys.count, 4)
        
        XCTAssertEqual(results["foo"]!.events, [
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO ")])
        
        XCTAssertEqual(results["bar"]!.events, [
            next(270, "baR  ")])
        
        XCTAssertEqual(results["baz"]!.events, [
            next(350, " Baz   ")])
        
        XCTAssertEqual(results["qux"]!.events, [
            next(360, "  qux ")])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            completed(570)
            ])
        
        let results: TestableObserver<String> = scheduler.createObserver(String.self)
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                return x.lowercased().trimWhitespace()
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        scheduler.scheduleAt(600) {
            innerSubscription = inner?.subscribe(results)
        }
        
        scheduler.scheduleAt(Defaults.disposed) {
            outerSubscription?.dispose()
            innerSubscription?.dispose()
        }
        
        scheduler.start()

        XCTAssertEqual(results.events, [
            completed(600)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            error(570, testError)
            ])
        
        let results: TestableObserver<String> = scheduler.createObserver(String.self)
        var outer: Observable<GroupedObservable<String, String>>?
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        scheduler.scheduleAt(Defaults.created) {
            outer = xs.groupBy { x in
                return x.lowercased().trimWhitespace()
            }
        }
        
        scheduler.scheduleAt(Defaults.subscribed) {
            outerSubscription = outer!.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        scheduler.scheduleAt(600) {
            innerSubscription = inner?.subscribe(results)
        }
        
        scheduler.scheduleAt(Defaults.disposed) { () -> Void in
            outerSubscription?.dispose()
            innerSubscription?.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            error(600, testError)])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 570)])
    }

    func testGroupBy_InnerEscapeDispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(220, "  foo"),
            next(240, " FoO "),
            next(310, "foO "),
            next(470, "FOO "),
            next(530, "    fOo    "),
            error(570, testError)
            ])
        
        let results: TestableObserver<String> = scheduler.createObserver(String.self)
        var outerSubscription: Disposable?
        var inner: GroupedObservable<String, String>?
        var innerSubscription: Disposable?
        
        scheduler.scheduleAt(Defaults.subscribed) {
            let outer: Observable<GroupedObservable<String, String>> = xs.groupBy { x in
                return x.lowercased().trimWhitespace()
            }
            outerSubscription = outer.subscribe(onNext: { (group: GroupedObservable<String, String>) -> Void in
                inner = group
            })
        }
        
        scheduler.scheduleAt(400) {
            outerSubscription?.dispose()
        }

        scheduler.scheduleAt(600) {
            innerSubscription = inner?.subscribe(results)
        }

        scheduler.scheduleAt(Defaults.disposed) {
            innerSubscription?.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(results.events, [])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)])
    }

    #if TRACE_RESOURCES
        func testGroupByReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).groupBy { $0 }.subscribe()
        }

        func testGroupByReleasesResourcesOnError1() {
            _ = Observable<Int>.error(testError).groupBy { $0 }.subscribe()
        }

        func testGroupByReleasesResourcesOnError2() {
            _ = Observable<Int>.error(testError).groupBy { x -> Int in throw testError }.subscribe()
        }
    #endif
}

extension String {
    fileprivate func trimWhitespace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
