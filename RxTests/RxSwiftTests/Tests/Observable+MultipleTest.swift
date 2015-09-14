//
//  Observable+MultipleTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class ObservableMultipleTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// onError
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
                return o2
            }
        }
        
        XCTAssertEqual(230, handlerCalled!)
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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

// switch
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
        
        let xSequence: [Recorded<Observable<Int>>] = [
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
        
        XCTAssertEqual(res.messages, correct)
        
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
        
        let xSequence: [Recorded<Observable<Int>>] = [
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
        
        XCTAssertEqual(res.messages, correct)
        
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
        
        let xSequence: [Recorded<Observable<Int>>] = [
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
        
        XCTAssertEqual(res.messages, correct)
        
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

// concat

extension ObservableMultipleTest {
    func testConcat_DefaultScheduler() {
        var sum = 0
        [just(1), just(2), just(3)].concat().subscribeNext { (e) -> Void in
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
        
        _ = scheduler.start {
            [xs1, xs2, xs3].concat()
        }
        
        _ = [
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
        
        let _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            completed(250)
        ]
        
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
        
        let _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            completed(250)
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            error(250, testError)
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            error(230, testError)
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            error(230, testError1)
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            next(210, 1),
            completed(250)
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _:[Recorded<Int>] = [
            next(240, 1),
            completed(250)
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _:[Recorded<Int>] = [
            next(210, 1),
        ]
        
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
        
        let _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
        ]
        
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
        
        _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _ : [Recorded<Int>] = [
            next(220, 2),
            next(240, 3),
            completed(250)
        ]
        
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
        
        let _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            error(230, testError1)
        ]
        
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
        
        let _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            next(220, 2),
            error(250, testError1)
        ]
        
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
        
        let _ = scheduler.start {
            [xs1, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
            next(210, 1),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
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
        
        let _ = scheduler.start {
            [xs1, xs2, xs3, xs2].concat()
        }
        
        let _: [Recorded<Int>] = [
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
}

// merge

extension ObservableMultipleTest {
    func testMerge_DeadlockSimple() {
        var nEvents = 0
        
        let observable = sequenceOf(
            sequenceOf(0, 1, 2),
            sequenceOf(0, 1, 2),
            sequenceOf(0, 1, 2)
        ).merge()
        
        let _ = observable .subscribeNext { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 9)
    }
    
    func testMerge_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = sequenceOf(
            sequenceOf(0, 1, 2),
            [sequenceOf(0, 1), failWith(testError)].concat(),
            sequenceOf(0, 1, 2)
        ).merge()
        
        let _ = observable .subscribeError { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = just(
            failWith(testError)
        ).merge()
        let _ = observable .subscribeError { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = (empty() as Observable<Observable<Int>>).merge()
        let _ = observable .subscribeCompleted {
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockFirstEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = just(empty()).merge()
        let _ = observable .subscribeCompleted { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockSimple() {
        var nEvents = 0
        
        let observable = sequenceOf(
            sequenceOf(0, 1, 2),
            sequenceOf(0, 1, 2),
            sequenceOf(0, 1, 2)
        ).merge(maxConcurrent: 1)
        
        let _ = observable .subscribeNext { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 9)
    }
    
    func testMergeConcurrent_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = sequenceOf(
            sequenceOf(0, 1, 2),
            [sequenceOf(0, 1), failWith(testError)].concat(),
            sequenceOf(0, 1, 2)
        ).merge(maxConcurrent: 1)
        
        let _ = observable .subscribeError { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = just(
            failWith(testError)
        ).merge(maxConcurrent: 1)
        let _ = observable .subscribeError { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = (empty() as Observable<Observable<Int>>).merge(maxConcurrent: 1)
        let _ = observable .subscribeCompleted {
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockFirstEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = just(empty()).merge(maxConcurrent: 1)
        let _ = observable .subscribeCompleted { n in
            nEvents++
        } .scopedDispose
        
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
        
        let xs: Observable<Observable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
        ])
        
        let _ = scheduler.start {
            xs.merge()
        }
        
        let _ = [
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
            ])
        
        let _ = scheduler.start {
            xs.merge()
        }
        
        let _ = [
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
            ])
        
        let _ = scheduler.start {
            xs.merge()
        }
        
        let _ = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(600, testError1)
        ]
        
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            error(500, testError1),
            ])
        
        let _ = scheduler.start {
            xs.merge()
        }
        
        let _ = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(600, testError1)
        ]
        
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let _ = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let _ = [
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let _ = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let _ = [
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(450)
            ])
        
        let _ = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let _ = [
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(750)
            ])
        
        let _ = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let _ = [
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let _ = scheduler.start(450) {
            xs.merge(maxConcurrent: 2)
        }
        
        let _ = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7)
        ]
        
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            error(400, testError1)
            ])
        
        let _ = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let _ = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            error(400, testError1)
        ]
        
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
        
        let xs: HotObservable<Observable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let _ = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let _ = [
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

// combine latest

extension ObservableMultipleTest {
    func testCombineLatest_DeadlockSimple() {
        var nEvents = 0
        
        let observable = combineLatest(sequenceOf(0, 1, 2), sequenceOf(0, 1, 2)) { $0 + $1 }
        let _ = observable .subscribeNext { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 3)
    }
    
    func testCombineLatest_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = combineLatest(
            [sequenceOf(0, 1, 2), failWith(testError)].concat(),
            sequenceOf(0, 1, 2)
        ) { $0 + $1 }
        let _ = observable .subscribeError { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testCombineLatest_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable = combineLatest(
            failWith(testError),
            sequenceOf(0, 1, 2)
            ) { $0 + $1 }
        let _ = observable .subscribeError { n in
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testReplay_DeadlockEmpty() {
        var nEvents = 0
        
        
        let observable = combineLatest(
            empty(),
            sequenceOf(0, 1, 2)
            ) { $0 + $1 }
        let _ = observable .subscribeCompleted {
            nEvents++
        } .scopedDispose
        
        XCTAssertEqual(nEvents, 1)
    }
}

// takeUntil

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
            l .takeUntil(r)
        }
    
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }

        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .doOn { _ in sourceNotDisposed = true } .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r .doOn { _ in sourceNotDisposed = true })
        }
        
        XCTAssertEqual(res.messages, [
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
            l .takeUntil(r)
        }
        
        XCTAssertEqual(res.messages, [
            error(225, testError),
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
}


// amb

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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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

// combineLatest + CollectionType

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
        
        XCTAssertEqual(res.messages, [])
     
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
        
        XCTAssertEqual(res.messages, [])
        
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
        
        XCTAssertEqual(res.messages, [])
        
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
            ([e0, e1] as [HotObservable<Int>]).combineLatest { $0.reduce(0, combine:+) }
        }
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertTrue(res.messages == [
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
        
        XCTAssertTrue(res.messages == [
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
        
        XCTAssertEqual(res.messages, [
            next(220, 2 + 3),
            next(225, 3 + 4),
            next(230, 4 + 5),
            next(235, 4 + 6),
            next(240, 4 + 7),
            completed(250)
            ] as [Recorded<Int>])
        
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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

// zip + CollectionType

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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
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
        
        XCTAssertEqual(res.messages, [
            error(230, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e2.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e3.subscriptions, [Subscription(200, 230)])
    }
}