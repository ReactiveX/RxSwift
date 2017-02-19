//
//  Observable+MultipleTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableMultipleTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// MARK: catchError
extension ObservableMultipleTest {
    func testCatch_ErrorSpecific_Caught() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            error(230, testError)
        ])
        
        let o2 = scheduler.createHotObservable([
            next(240, 4),
            completed(250)
        ])
        
        var handlerCalled: Int?
        
        let res = scheduler.start {
            o1.catchError { e in
                handlerCalled = scheduler.clock
                return o2.asObservable()
            }
        }
        
        XCTAssertEqual(230, handlerCalled!)
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(240, 4),
            completed(250)
        ])
        
        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 230)
        ])
        
        XCTAssertEqual(o2.subscriptions, [
            Subscription(230, 250)
        ])
    }
    
    func testCatch_HandlerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let o1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            error(230, testError)
        ])
        
        var handlerCalled: Int?
        
        let res = scheduler.start {
            o1.catchError { e in
                handlerCalled = scheduler.clock
                throw testError1
            }
        }
        
        XCTAssertEqual(230, handlerCalled!)
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            error(230, testError1),
        ])
        
        XCTAssertEqual(o1.subscriptions, [
            Subscription(200, 230)
        ])
    }

    #if TRACE_RESOURCES
        func testCatchReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).catchError { _ in Observable<Int>.just(1) }.subscribe()
        }

        func tesCatch1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).catchError { _ in Observable<Int>.just(1) }.subscribe()
        }

        func tesCatch2ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).catchError { _ in Observable<Int>.error(testError) }.subscribe()
        }
    #endif
}

// catch enumerable
extension ObservableMultipleTest {
    func testCatchSequenceOf_IEofIO() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            next(30, 3),
            error(40, testError)
        ])
        
        let xs2 = scheduler.createColdObservable([
            next(10, 4),
            next(20, 5),
            error(30, testError)
        ])
        
        let xs3 = scheduler.createColdObservable([
            next(10, 6),
            next(20, 7),
            next(30, 8),
            next(40, 9),
            completed(50)
        ])
        
        let res = scheduler.start {
            Observable.catchError([xs1.asObservable(), xs2.asObservable(), xs3.asObservable()])
        }
        
        XCTAssertEqual(res.events, [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(250, 4),
            next(260, 5),
            next(280, 6),
            next(290, 7),
            next(300, 8),
            next(310, 9),
            completed(320)
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 240)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(240, 270)
            ])
        
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(270, 320)
            ])
    }
    
    func testCatchAnySequence_NoErrors() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(230)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(240, 4),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.catchError([xs1, xs2].map { $0.asObservable() })
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            completed(230)
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }

    func testCatchAnySequence_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(240, 4),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.catchError([xs1, xs2].map { $0.asObservable() })
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testCatchAnySequence_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(240, 4),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.catchError([xs1, xs2].map { $0.asObservable() })
        }
        
        XCTAssertEqual(res.events, [
            completed(230)
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testCatchSequenceOf_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            error(230, testError)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(240, 4),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.catchError([xs1, xs2].map { $0.asObservable() })
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(240, 4),
            completed(250)
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250)
            ])
    }
    
    func testCatchSequenceOf_ErrorNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            error(230, testError)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            Observable.catchError([xs1, xs2].map { $0.asObservable() })
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 1000)
            ])
    }
    
    func testCatchSequenceOf_ErrorError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            error(230, testError)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError)
            ])
        
        let res = scheduler.start {
            Observable.catchError([xs1, xs2].map { $0.asObservable() })
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            error(250, testError)
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250)
            ])
    }
    
    func testCatchSequenceOf_Multiple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(215, testError)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(220, 3),
            error(225, testError)
            ])
        
        let xs3 = scheduler.createHotObservable([
            next(230, 4),
            completed(235)
            ])
        
        let res = scheduler.start {
            Observable.catchError([xs1.asObservable(), xs2.asObservable(), xs3.asObservable()])
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            completed(235)
            ])
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 215)
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(215, 225)
            ])
        
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(225, 235)
            ])
    }

    #if TRACE_RESOURCES
        func testCatchSequenceReleasesResourcesOnComplete() {
            _ = Observable.catchError([Observable<Int>.just(1)]).subscribe()
        }
    #endif
}

// MARK: switch
extension ObservableMultipleTest {

    func testSwitch_Data() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
        ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
        ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            completed(150)
        ])
        
        let xSequence = [
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
        ]
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.switchLatest()
        }
        
        let correct = [
            next(310, 101),
            next(320, 102),
            next(410, 201),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            next(510, 301),
            next(520, 302),
            next(530, 303),
            next(540, 304),
            completed(650)
        ]
        
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
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            error(50, testError)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            completed(150)
            ])
        
        let xSequence = [
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
        ]
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.switchLatest()
        }
        
        let correct = [
            next(310, 101),
            next(320, 102),
            next(410, 201),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(450, testError),
        ]
        
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
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
            ])
        
        let xSequence = [
            next(300, ys1),
            next(400, ys2),
            error(500, testError)
        ]
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.switchLatest()
        }
        
        let correct = [
            next(310, 101),
            next(320, 102),
            next(410, 201),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(500, testError),
        ]
        
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

// MARK: switchIfEmpty
extension ObservableMultipleTest {
    func testSwitchIfEmpty_SourceNotEmpty_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            next(205, 1),
            completed(210, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            completed(50)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            next(205, 1),
            completed(210)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            ])
    }

    func testSwitchIfEmpty_SourceNotEmptyError_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            next(205, 1),
            error(210, testError)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            completed(50)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            next(205, 1),
            error(210, testError)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            ])
    }

    func testSwitchIfEmpty_SourceEmptyError_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            error(210, testError, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            completed(50)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            ])
    }

    func testSwitchIfEmpty_SourceEmpty_SwitchCompletes() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
                completed(210, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
                next(10, 0),
                next(20, 1),
                next(30, 2),
                next(40, 3),
                completed(50)
            ])
        
        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }
        
        XCTAssertEqual(res.events, [
                next(220, 0),
                next(230, 1),
                next(240, 2),
                next(250, 3),
                completed(260)
            ])
        XCTAssertEqual(source.subscriptions, [
                Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
                Subscription(210, 260)
            ])
    }

    func testSwitchIfEmpty_SourceEmpty_SwitchError() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
            completed(210, Int.self)
            ])
        let switchSource = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            error(50, testError)
            ])

        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }

        XCTAssertEqual(res.events, [
            next(220, 0),
            next(230, 1),
            next(240, 2),
            next(250, 3),
            error(260, testError)
            ])
        XCTAssertEqual(source.subscriptions, [
            Subscription(200, 210)
            ])
        XCTAssertEqual(switchSource.subscriptions, [
            Subscription(210, 260)
            ])
    }

    func testSwitchIfEmpty_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        let source = scheduler.createHotObservable([
                next(0, 0)
            ])
        let switchSource = scheduler.createColdObservable([
                next(10, 0),
                next(20, 1),
                next(30, 2),
                next(40, 3),
                completed(50)
            ])
        
        let res = scheduler.start {
            return source.ifEmpty(switchTo: switchSource.asObservable())
        }
        
        XCTAssertEqual(res.events, [])
        XCTAssertEqual(source.subscriptions, [
                Subscription(200, 1000)
            ])
        XCTAssertEqual(switchSource.subscriptions, [])
    }

    #if TRACE_RESOURCES
        func testSwitchIfEmptyReleasesResourcesOnComplete1() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).ifEmpty(switchTo: Observable.just(1)).subscribe()

            testScheduler.start()
        }
        func testSwitchIfEmptyReleasesResourcesOnComplete2() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.empty().ifEmpty(switchTo: Observable.just(1)).subscribe()

            testScheduler.start()
        }
        func testSwitchIfEmptyReleasesResourcesOnError1() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).ifEmpty(switchTo: Observable.just(1)).subscribe()

            testScheduler.start()
        }

        func testSwitchIfEmptyReleasesResourcesOnError2() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.empty().ifEmpty(switchTo: Observable<Int>.error(testError)).subscribe()

            testScheduler.start()
        }
    #endif
}

// MARK: flatMapLatest
extension ObservableMultipleTest {

    func testFlatMapLatest_Data() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
        ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
        ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            completed(150)
        ])

        let observables = [ys1, ys2, ys3]
        
        let xSequence = [
            next(300, 0),
            next(400, 1),
            next(500, 2),
            completed(600)
        ]
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.flatMapLatest { observables[$0] }
        }
        
        let correct = [
            next(310, 101),
            next(320, 102),
            next(410, 201),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            next(510, 301),
            next(520, 302),
            next(530, 303),
            next(540, 304),
            completed(650)
        ]
        
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
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            error(50, testError)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            completed(150)
            ])

        let observables = [ys1, ys2, ys3]
        
        let xSequence = [
            next(300, 0),
            next(400, 1),
            next(500, 2),
            completed(600)
        ]
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.flatMapLatest { observables[$0] }
        }
        
        let correct = [
            next(310, 101),
            next(320, 102),
            next(410, 201),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(450, testError),
        ]
        
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
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
            ])

        let observables = [ys1, ys2]
        
        let xSequence = [
            next(300, 0),
            next(400, 1),
            error(500, testError)
        ]
        
        let xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            xs.flatMapLatest { observables[$0] }
        }
        
        let correct = [
            next(310, 101),
            next(320, 102),
            next(410, 201),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(500, testError),
        ]
        
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
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])

        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
            ])

        let observables = [ys1, ys2]

        let xSequence = [
            next(300, 0),
            next(400, 1)
        ]

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

        let correct = [
            next(310, 101),
            next(320, 102),
            error(400, testError),
        ]

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

// this generates
// [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
func generateCollection<T>(_ startIndex: Int, _ generator: @escaping (Int) -> Observable<T>) -> Observable<T> {
    let all = [0, 1].lazy.map { i in
        return i == 0 ? generator(startIndex) : generateCollection(startIndex + 1, generator)
    }
    return Observable.concat(all)
}

// this generates
// [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
// This should
func generateSequence<T>(_ startIndex: Int, _ generator: @escaping (Int) -> Observable<T>) -> Observable<T> {
    let all = AnySequence([0, 1].lazy.map { i in
        return i == 0 ? generator(startIndex) : generateSequence(startIndex + 1, generator)
    })
    return Observable.concat(all)
}

// MARK: concat
extension ObservableMultipleTest {
    func testConcat_DefaultScheduler() {
        var sum = 0
        _ = Observable.concat([Observable.just(1), Observable.just(2), Observable.just(3)]).subscribe(onNext: { (e) -> Void in
            sum += e
        })
        
        XCTAssertEqual(sum, 6)
    }
    
    func testConcat_IEofIO() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            next(30, 3),
            completed(40),
        ])
        
        let xs2 = scheduler.createColdObservable([
            next(10, 4),
            next(20, 5),
            completed(30),
        ])
        
        let xs3 = scheduler.createColdObservable([
            next(10, 6),
            next(20, 7),
            next(30, 8),
            next(40, 9),
            completed(50)
        ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2, xs3].map { $0.asObservable() })
        }
        
        let messages = [
            next(210, 1),
            next(220, 2),
            next(230, 3),
            next(250, 4),
            next(260, 5),
            next(280, 6),
            next(290, 7),
            next(300, 8),
            next(310, 9),
            completed(320)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 240),
        ])

        XCTAssertEqual(xs2.subscriptions, [
            Subscription(240, 270),
        ])
        
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(270, 320),
        ])
    }
    
    func testConcat_EmptyEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            completed(250),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            completed(250, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_EmptyNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 1000),
            ])
    }
    
    func testConcat_NeverNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 1000),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_EmptyThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            error(250, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])

        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_ThrowEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            error(230, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ThrowThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError1),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError2)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            error(230, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ReturnEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            next(210, 2),
            completed(250)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_EmptyReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            next(240, 2),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            next(240, 2),
            completed(250)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_ReturnNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            next(210, 2),
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 1000),
            ])
    }
    
    func testConcat_NeverReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(230),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 1000),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ReturnReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(230)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            next(240, 3),
            completed(250),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            next(220, 2),
            next(240, 3),
            completed(250)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_ThrowReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError1)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            next(240, 2),
            completed(250),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            error(230, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ReturnThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(230)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError2),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            next(220, 2),
            error(250, testError2)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_SomeDataSomeData() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(225)
            ])
        
        let xs2 = scheduler.createHotObservable([
            next(150, 1),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 225),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(225, 250),
            ])
    }
    
    func testConcat_EnumerableTiming() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(230)
            ])
        
        let xs2 = scheduler.createColdObservable([
            next(50, 4),
            next(60, 5),
            next(70, 6),
            completed(80)
            ])
        
        let xs3 = scheduler.createHotObservable([
            next(150, 1),
            next(200, 2),
            next(210, 3),
            next(220, 4),
            next(230, 5),
            next(270, 6),
            next(320, 7),
            next(330, 8),
            completed(340)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2, xs3, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            next(210, 2),
            next(220, 3),
            next(280, 4),
            next(290, 5),
            next(300, 6),
            next(320, 7),
            next(330, 8),
            next(390, 4),
            next(400, 5),
            next(410, 6),
            completed(420)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 310),
            Subscription(340, 420),
            ])
        
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(310, 340),
            ])
        
    }

    func testConcat_variadicElementsOverload() {
        let elements = try! Observable.concat(Observable.just(1)).toBlocking().toArray()
        XCTAssertEqual(elements, [1])
    }

#if TRACE_RESOURCES
    func testConcat_TailRecursionCollection() {
        maxTailRecursiveSinkStackSize = 0
        let elements = try! generateCollection(0) { i in
                Observable.just(i, scheduler: CurrentThreadScheduler.instance)
            }
            .take(10000)
            .toBlocking()
            .toArray()

        XCTAssertEqual(elements, Array(0 ..< 10000))
        XCTAssertEqual(maxTailRecursiveSinkStackSize, 1)
    }

    func testConcat_TailRecursionSequence() {
        maxTailRecursiveSinkStackSize = 0
        let elements = try! generateSequence(0) { i in
                Observable.just(i, scheduler: CurrentThreadScheduler.instance)
            }
            .take(10000)
            .toBlocking()
            .toArray()

        XCTAssertEqual(elements, Array(0 ..< 10000))
        XCTAssertTrue(maxTailRecursiveSinkStackSize > 1000)
    }
#endif


    #if TRACE_RESOURCES
        func testConcatReleasesResourcesOnComplete() {
            _ = Observable.concat([Observable.just(1)]).subscribe()
        }

        func testConcatReleasesResourcesOnError() {
            _ = Observable.concat([Observable<Int>.error(testError)]).subscribe()
        }
    #endif
}


