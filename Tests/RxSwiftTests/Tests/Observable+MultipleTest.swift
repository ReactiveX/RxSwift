//
//  Observable+MultipleTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTests

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
            [xs1, xs2, xs3].catchError()
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
            [xs1, xs2].catchError()
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
            [xs1, xs2].catchError()
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
            [xs1, xs2].catchError()
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
            [xs1, xs2].catchError()
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
            [xs1, xs2].catchError()
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
            [xs1, xs2].catchError()
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
            [xs1, xs2, xs3].catchError()
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
}

// this generates
// [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
func generateCollection<T>(startIndex: Int, _ generator: Int -> Observable<T>) -> Observable<T> {
    let all = [0, 1].lazy.map { i in
        return i == 0 ? generator(startIndex) : generateCollection(startIndex + 1, generator)
    }
    return all.concat()
}

// this generates
// [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
// This should
func generateSequence<T>(startIndex: Int, _ generator: Int -> Observable<T>) -> Observable<T> {
    let all = AnySequence([0, 1].lazy.map { i in
        return i == 0 ? generator(startIndex) : generateSequence(startIndex + 1, generator)
    })
    return all.concat()
}

// MARK: concat
extension ObservableMultipleTest {
    func testConcat_DefaultScheduler() {
        var sum = 0
        _ = [Observable.just(1), Observable.just(2), Observable.just(3)].concat().subscribeNext { (e) -> Void in
            sum += e
        }
        
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
            [xs1, xs2, xs3].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1, xs2].concat()
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
            [xs1.asObservable(), xs2.asObservable(), xs3.asObservable(), xs2.asObservable()].concat()
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
}

// MARK: merge
extension ObservableMultipleTest {
    func testMerge_DeadlockSimple() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2)
        ).merge()
        
        _ = observable.subscribeNext { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 9)
    }
    
    func testMerge_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            [Observable.of(0, 1), Observable.error(testError)].concat(),
            Observable.of(0, 1, 2)
        ).merge()
        
        _ = observable.subscribeError { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = Observable.just(
            Observable.error(testError)
        ).merge()

        _ = observable.subscribeError { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable<Observable<Int>>.empty().merge()
        _ = observable.subscribeCompleted {
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockFirstEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable.just(Observable.empty()).merge()
        _ = observable.subscribeCompleted { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockSimple() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2)
        ).merge(maxConcurrent: 1)
        
        _ = observable.subscribeNext { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 9)
    }
    
    func testMergeConcurrent_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            [Observable.of(0, 1), Observable.error(testError)].concat(),
            Observable.of(0, 1, 2)
        ).merge(maxConcurrent: 1)
        
        _ = observable.subscribeError { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = Observable.just(
            Observable.error(testError)
        ).merge(maxConcurrent: 1)

        _ = observable.subscribeError { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable<Observable<Int>>.empty().merge(maxConcurrent: 1)

        _ = observable.subscribeCompleted {
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockFirstEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable.just(Observable.empty()).merge(maxConcurrent: 1)

        _ = observable.subscribeCompleted { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_ObservableOfObservable_Data() {
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
            next(120, 305),
            completed(150)
        ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
        ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            next(510, 105),
            next(510, 301),
            next(520, 106),
            next(520, 302),
            next(530, 303),
            next(540, 304),
            next(620, 305),
            completed(650)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 530),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(500, 650),
            ])
    }
    
    func testMerge_ObservableOfObservable_Data_NotOverlapped() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(10, 101),
            next(20, 102),
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
            completed(50)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
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
            completed(600)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 530),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(500, 550),
            ])
    }
    
    func testMerge_ObservableOfObservable_InnerThrows() {
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
            error(50, testError1)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            completed(150)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(450, testError1)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 450),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            ])
    }
    
    func testMerge_ObservableOfObservable_OuterThrows() {
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
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            error(500, testError1),
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(500, testError1)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 500),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 500),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
    }
    
    func testMerge_MergeConcat_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7),
            next(460, 8),
            next(670, 9),
            next(700, 10),
            completed(760)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 460),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 480),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(460, 760),
            ])
    }
    
    func testMerge_MergeConcat_BasicLong() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7),
            next(460, 8),
            next(690, 9),
            next(720, 10),
            completed(780)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 560),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 480),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(480, 780),
            ])
    }
    
    func testMerge_MergeConcat_BasicWide() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(450)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(280, 6),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 7),
            next(380, 8),
            next(630, 9),
            next(660, 10),
            completed(720)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 560),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(270, 400),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(420, 720),
            ])
    }
    
    func testMerge_MergeConcat_BasicLate() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(750)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(280, 6),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 7),
            next(380, 8),
            next(630, 9),
            next(660, 10),
            completed(750)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 750),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 560),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(270, 400),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(420, 720),
            ])
    }
    
    func testMerge_MergeConcat_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start(450) {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 450),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            ])
    }
    
    func testMerge_MergeConcat_OuterError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            error(400, testError1)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            error(400, testError1)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 400),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 400),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            ])
    }
    
    func testMerge_MergeConcat_InnerError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            error(140, testError1)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7),
            next(460, 8),
            error(490, testError1)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 460),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 490),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(460, 490),
            ])
    }
}

// MARK: combine latest
extension ObservableMultipleTest {
    func testCombineLatest_DeadlockSimple() {
        var nEvents = 0
        
        let observable = Observable.combineLatest(Observable.of(0, 1, 2), Observable.of(0, 1, 2)) { $0 + $1 }
        _ = observable.subscribeNext { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 3)
    }
    
    func testCombineLatest_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = Observable.combineLatest(
            [Observable.of(0, 1, 2), Observable.error(testError)].concat(),
            Observable.of(0, 1, 2)
        ) { $0 + $1 }

        _ = observable.subscribeError { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testCombineLatest_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable = Observable.combineLatest(
            Observable.error(testError),
            Observable.of(0, 1, 2)
        ) { $0 + $1 }

        _ = observable.subscribeError { n in
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testReplay_DeadlockEmpty() {
        var nEvents = 0
        
        
        let observable = Observable.combineLatest(
            Observable.empty(),
            Observable.of(0, 1, 2)
            ) { $0 + $1 }

        _ = observable.subscribeCompleted {
            nEvents += 1
        }
        
        XCTAssertEqual(nEvents, 1)
    }
}

// MARK: takeUntil
extension ObservableMultipleTest {
    func testTakeUntil_Preempt_SomeData_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 99),
            completed(230)
        ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
    
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            completed(225)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testTakeUntil_Preempt_SomeData_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }

        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            error(225, testError)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_SomeData_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
        ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_SomeData_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testTakeUntil_Preempt_Never_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 2),
            completed(250)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(225)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_Preempt_Never_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(225, testError)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }

    func testTakeUntil_NoPreempt_Never_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_Never_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testTakeUntil_Preempt_BeforeFirstProduced() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(230, 2),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(210)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testTakeUntil_Preempt_BeforeFirstProduced_RemainSilentAndProperDisposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            error(215, testError),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
            ])
        
        var sourceNotDisposed = false
        
        let res = scheduler.start {
            l.doOn { _ in sourceNotDisposed = true } .takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(210)
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
    
    func testTakeUntil_NoPreempt_AfterLastProduced_ProperDisposedSigna() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(230, 2),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            completed(260)
            ])
        
        var sourceNotDisposed = false
        
        let res = scheduler.start {
            l.takeUntil(r .doOn { _ in sourceNotDisposed = true })
        }
        
        XCTAssertEqual(res.events, [
            next(230, 2),
            completed(240)
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
    
    func testTakeUntil_Error_Some() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(240, 2),
            ])
        
        let sourceNotDisposed = false
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(225, testError),
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
}


// MARK: amb
extension ObservableMultipleTest {
    
    func testAmb_Never2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testAmb_Never3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let x3 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start {
            [x1, x2, x3].amb()
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(x3.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testAmb_Never_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            completed(225)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testAmb_RegularShouldDisposeLoser() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(240)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            completed(240)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 240)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testAmb_WinnerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(220, testError)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            error(220, testError)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 220)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testAmb_LoserThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            error(230, testError)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 3),
            completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 3),
            completed(250)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testAmb_ThrowsBeforeElectionLeft() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(250)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            error(210, testError)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testAmb_ThrowsBeforeElectionRight() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let x1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(250)
            ])
        
        let x2 = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError)
            ])
        
        let res = scheduler.start {
            x1.amb(x2)
        }
        
        XCTAssertEqual(res.events, [
            error(210, testError)
            ])
        
        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 210)
            ])
    }
}

// MARK: combineLatest + CollectionType
extension ObservableMultipleTest {
    func testCombineLatest_NeverN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1)
        ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1)
        ])
        
        let e2 = scheduler.createHotObservable([
            next(150, 1)
        ])
        
        let res = scheduler.start {
            [e0, e1, e2].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [])
     
        for e in [e0, e1, e2] {
            XCTAssertEqual(e.subscriptions, [Subscription(200, 1000)])
        }
    }
    
    func testCombineLatest_NeverEmptyN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
    }
    
    func testCombineLatest_EmptyNeverN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 1000)])
    }
    
    func testCombineLatest_EmptyReturnN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
            ])
        
        let res = scheduler.start {
            ([e0, e1] as [TestableObservable<Int>]).combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            completed(215)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 215)])
    }
    
    func testCombineLatest_ReturnReturnN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(240)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            next(220, 2 + 3),
            completed(240)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 240)])
    }
    
    func testCombineLatest_EmptyErrorN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError),
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ReturnErrorN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError),
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ErrorErrorN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError1)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError2),
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError1)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_NeverErrorN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError2),
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError2)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_SomeErrorN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError2),
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError2)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ErrorAfterCompletedN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError2),
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            error(230, testError2)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
    }
    
    func testCombineLatest_InterleavedWithTailN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            next(225, 4),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            next(230, 5),
            next(235, 6),
            next(240, 7),
            completed(250)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            next(220, 2 + 3),
            next(225, 3 + 4),
            next(230, 4 + 5),
            next(235, 4 + 6),
            next(240, 4 + 7),
            completed(250)
            ] as [Recorded<Event<Int>>])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
    }
    
    func testCombineLatest_ConsecutiveN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            next(225, 4),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(235, 6),
            next(240, 7),
            completed(250)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            next(235, 4 + 6),
            next(240, 4 + 7),
            completed(250)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
    }
    
    func testCombineLatest_ConsecutiveNWithErrorLeft() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            next(225, 4),
            error(230, testError)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(235, 6),
            next(240, 7),
            completed(250)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            error(230, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
    }
    
    func testCombineLatest_ConsecutiveNWithErrorRight() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            next(225, 4),
            completed(250)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(235, 6),
            next(240, 7),
            error(245, testError)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            next(235, 4 + 6),
            next(240, 4 + 7),
            error(245, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 245)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 245)])
    }
    
    func testCombineLatest_SelectorThrowsN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(240)
            ])
        
        let res = scheduler.start {
            [e0, e1].combineLatest { x throws -> Int in throw testError }
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_willNeverBeAbleToCombineN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            completed(260)
            ])
        
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            next(500, 2),
            completed(800)
            ])
        
        let res = scheduler.start {
            [e0, e1, e2].combineLatest { _ in 42 }
        }
        
        XCTAssertEqual(res.events, [
            completed(500)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 260)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 500)])
    }
    
    func testCombineLatest_typicalN() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            next(410, 4),
            completed(800)
        ])
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(420, 5),
            completed(800)
        ])
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            next(230, 3),
            next(430, 6),
            completed(800)
        ])
        
        let res = scheduler.start {
            [e0, e1, e2].combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.events, [
            next(230, 6),
            next(410, 9),
            next(420, 12),
            next(430, 15),
            completed(800)
            ])
        
        for e in [e0, e1, e2] {
            XCTAssertEqual(e.subscriptions, [Subscription(200, 800)])
        }
    }
    
    func testCombineLatest_NAry_symmetric() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            next(250, 4),
            completed(420)
            ])
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 5),
            completed(410)
            ])
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            next(230, 3),
            next(260, 6),
            completed(400)
            ])
        
        let res = scheduler.start {
            [e0, e1, e2].combineLatest { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(230, EquatableArray([1, 2, 3])),
            next(240, EquatableArray([1, 5, 3])),
            next(250, EquatableArray([4, 5, 3])),
            next(260, EquatableArray([4, 5, 6])),
            completed(420)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 420)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 410)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 400)])
        
    }
    
    func testCombineLatest_NAry_asymmetric() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            next(250, 4),
            completed(270)
            ])
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 5),
            next(290, 7),
            next(310, 9),
            completed(410)
            ])
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            next(230, 3),
            next(260, 6),
            next(280, 8),
            completed(300)
            ])
        
        let res = scheduler.start {
            [e0, e1, e2].combineLatest { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(230, EquatableArray([1, 2, 3])),
            next(240, EquatableArray([1, 5, 3])),
            next(250, EquatableArray([4, 5, 3])),
            next(260, EquatableArray([4, 5, 6])),
            next(280, EquatableArray([4, 5, 8])),
            next(290, EquatableArray([4, 7, 8])),
            next(310, EquatableArray([4, 9, 8])),
            completed(410)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 270)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 410)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 300)])
        
    }
}

// MARK: zip + CollectionType
extension ObservableMultipleTest {
    func testZip_NAry_symmetric() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            next(250, 4),
            completed(420)
            ])
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 5),
            completed(410)
            ])
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            next(230, 3),
            next(260, 6),
            completed(400)
            ])
        
        let res = scheduler.start {
            [e0, e1, e2].zip { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(230, EquatableArray([1, 2, 3])),
            next(260, EquatableArray([4, 5, 6])),
            completed(420)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 420)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 410)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 400)])
        
    }
    
    func testZip_NAry_asymmetric() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            next(250, 4),
            completed(270)
            ])
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 5),
            next(290, 7),
            next(310, 9),
            completed(410)
            ])
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            next(230, 3),
            next(260, 6),
            next(280, 8),
            completed(300)
            ])
        
        let res = scheduler.start {
            [e0, e1, e2].zip { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(230, EquatableArray([1, 2, 3])),
            next(260, EquatableArray([4, 5, 6])),
            completed(310)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 270)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 310)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 300)])
        
    }
    
    func testZip_NAry_error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            error(250, testError),
            ])
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 5),
            completed(410)
            ])
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            next(230, 3),
            next(260, 6),
            completed(400)
            ])
        
        let res = scheduler.start {
            [e0, e1, e2].zip { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            next(230, EquatableArray([1, 2, 3])),
            error(250, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 250)])
    }
    
    func testZip_NAry_atLeastOneErrors4() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            completed(400)
            ])
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(400)
            ])
        let e2 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError)
            ])
        let e3 = scheduler.createHotObservable([
            next(150, 1),
            next(240, 4),
            completed(400)
            ])
        
        let res = scheduler.start {
            [e0, e1, e2, e3].zip { _ in 42 }
        }
        
        XCTAssertEqual(res.events, [
            error(230, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e3.subscriptions, [Subscription(200, 230)])
    }
}


// MARK:  skipUntil
extension ObservableMultipleTest {
    func testSkipUntil_SomeData_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4), //!
            next(240, 5), //!
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 99),
            completed(230)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
    
        XCTAssertEqual(res.events, [
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_SomeData_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
    
        XCTAssertEqual(res.events, [
            error(225, testError),
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Error_SomeData() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(220, testError)
 
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(230, 2),
            completed(250)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError),
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 220)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 220)
        ])
    }
    
    func testSkipUntil_SomeData_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Never_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 2), //!
            completed(250)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Never_Error1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(225, testError)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_SomeData_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(300, testError)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(300, testError)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 300)
        ])
    }
    
    func testSkipUntil_SomeData_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 1000)
        ])
    }
    
    func testSkipUntil_Never_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
        ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testSkipUntil_Never_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
        ])
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 1000)
        ])
    }
    
    func testSkipUntil_HasCompletedCausesDisposal() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var disposed = false
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r: Observable<Int> = Observable.create { o in
            return AnonymousDisposable {
                disposed = true
            }
        }
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssert(disposed, "disposed")
    }
}


// MARK: withLatestFrom
extension ObservableMultipleTest {
    
    func testWithLatestFrom_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            next(410, 7),
            next(420, 8),
            next(470, 9),
            next(550, 10),
            completed(590)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            next(410, "7qux"),
            next(420, "8qux"),
            next(470, "9qux"),
            next(550, "10qux"),
            completed(590)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 590)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 400)
        ])
    }
    
    func testWithLatestFrom_TwoObservablesWithImmediateValues() {
        let xs = BehaviorSubject<Int>(value: 3)
        let ys = BehaviorSubject<Int>(value: 5)
        
        let scheduler = TestScheduler(initialClock: 0)

        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
                .take(1)
        }
        
        XCTAssertEqual(res.events, [
            next(200, "35"),
            completed(200)
        ])
    }
    
    func testWithLatestFrom_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            next(370, "baz"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            completed(390)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 390)
        ])
    }
    
    func testWithLatestFrom_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(245, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            next(370, "baz"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(250, "3bar"),
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            completed(390)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 390)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 390)
        ])
    }
    
    func testWithLatestFrom_Error1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            next(410, 7),
            next(420, 8),
            next(470, 9),
            next(550, 10),
            error(590, testError)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            next(410, "7qux"),
            next(420, "8qux"),
            next(470, "9qux"),
            next(550, "10qux"),
            error(590, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 590)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 400)
        ])
    }
    
    func testWithLatestFrom_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            error(370, testError)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            error(370, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 370)
        ])
    }
    
    func testWithLatestFrom_Error3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            completed(390)
        ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
        ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) {
                (x, y) throws -> String in
                if x == 5 {
                    throw testError
                }
                return "\(x)\(y)"
            }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            error(310, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 310)
        ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 310)
        ])
    }

    func testWithLatestFrom_MakeSureDefaultOverloadTakesSecondSequenceValues() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            next(410, 7),
            next(420, 8),
            next(470, 9),
            next(550, 10),
            completed(590)
            ])

        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
            ])

        let res = scheduler.start {
            xs.withLatestFrom(ys)
        }

        XCTAssertEqual(res.events, [
            next(260, "bar"),
            next(310, "bar"),
            next(340, "foo"),
            next(410, "qux"),
            next(420, "qux"),
            next(470, "qux"),
            next(550, "qux"),
            completed(590)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 590)
            ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 400)
            ])
    }
}