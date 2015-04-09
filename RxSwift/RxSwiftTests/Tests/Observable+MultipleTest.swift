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
        
        var xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            switchLatest(xs)
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
        
        var xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            switchLatest(xs)
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
        
        var xs = scheduler.createHotObservable(xSequence)
        
        let res = scheduler.start {
            switchLatest(xs)
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


// combine latest
extension ObservableMultipleTest {
    func testCombineLatest_Never2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1)
        ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1)
        ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (_, _) -> Int in
                return (42)
            })
        }
        
        XCTAssertEqual(res.messages, [])
        
        let subscriptions = [Subscription(200, 1000)]
        
        for e in [e0, e1] {
            XCTAssertEqual(e.subscriptions, subscriptions)
        }
    }
    
    func testCombineLatest_NeverEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
    }
    
    func testCombineLatest_EmptyNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 1000)])
    }
    
    func testCombineLatest_Empty2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            completed(220)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (_, _) -> Int in
                return (42)
            })
        }
        
        XCTAssertEqual(res.messages, [completed(220)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_EmptyReturn() {
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
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [completed(215)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 215)])
    }
    
    func testCombineLatest_ReturnEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [completed(215)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 215)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
    }
    
    func testCombineLatest_NeverReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 1000)])
    }

    func testCombineLatest_ReturnNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ReturnReturn1() {
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
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [next(220, (2 + 3)), completed(240)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 240)])
    }

    func testCombineLatest_ReturnReturn2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 3),
            completed(240)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [next(220, (2 + 3)), completed(240)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 240)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
    }
    
    func testCombineLatest_EmptyError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ErrorEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ReturnThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ThrowReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(230)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ThrowThrow1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError1),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError2),
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError1)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ThrowThrow2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError1),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError2),
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError2)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ErrorThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(220, testError1),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError2),
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError1)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ThrowError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError2),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(220, testError1),
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError1)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_SomeThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError),
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ThrowSome() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(220, testError),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(230)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(220, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_ThrowAfterCompleteLeft() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError),
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(230, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
    }
    
    func testCombineLatest_ThrowAfterCompleteRight() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            error(230, testError),
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(215, 2),
            completed(220)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(230, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_TestInterleavedWithTail() {
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
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        let messages = [
            next(220, 2 + 3),
            next(225, 3 + 4),
            next(230, 4 + 5),
            next(235, 4 + 6),
            next(240, 4 + 7),
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
    }
    
    func testCombineLatest_Consecutive() {
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
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        let messages = [
            next(235, 4 + 6),
            next(240, 4 + 7),
            completed(250)
        ]
        
        XCTAssertEqual(res.messages, messages)
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
    }
    
    func testCombineLatest_ConsecutiveEndWithErrorLeft() {
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
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [error(230, testError)])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
    }
    
    func testCombineLatest_ConsecutiveEndWithErrorRight() {
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
            e0 >- combineLatest(e1, { (x1, x2) -> Int in
                return (x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [
            next(235, 4 + 6),
            next(240, 4 + 7),
            error(245, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 245)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 245)])
    }
    
    func testCombineLatest_SelectorThrows() {
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
            e0 >- combineLatestOrDie(e1, { (x1, x2) -> Result<Int> in
                return .Error(testError)
            })
        }
        
        XCTAssertEqual(res.messages, [
            error(220, testError)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_WillNeverBeAbleToCombine2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(500, 3),
            completed(800)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatestOrDie(e1, { (x1, x2) -> Result<Int> in
                return .Error(testError)
            })
        }
        
        XCTAssertEqual(res.messages, [
            completed(500)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 500)])
    }
    
    func testCombineLatest_Typical2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let e0 = scheduler.createHotObservable([
            next(150, 1),
            next(210, 1),
            next(410, 3),
            completed(800)
            ])
        
        let e1 = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(420, 4),
            completed(800)
            ])
        
        let res = scheduler.start {
            e0 >- combineLatestOrDie(e1, { (x1, x2) -> Result<Int> in
                return success(x1 + x2)
            })
        }
        
        XCTAssertEqual(res.messages, [
            next(220, 3),
            next(410, 5),
            next(420, 7),
            completed(800)
            ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 800)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 800)])
    }
}

// concat

extension ObservableMultipleTest {
    func testConcat_DefaultScheduler() {
        var sum = 0
        concat([returnElement(1), returnElement(2), returnElement(3)]) >- subscribeNext { (e) -> Void in
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
            concat([xs1, xs2, xs3])
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
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            concat([xs1, xs2, xs3, xs2])
        }
        
        let messages: [Recorded<Int>] = [
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
        
        let res = scheduler.start {
            xs >- merge
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
        
        let res = scheduler.start {
            xs >- merge
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
        
        let res = scheduler.start {
            xs >- merge
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
        
        let res = scheduler.start {
            xs >- merge
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
        
        let res = scheduler.start {
            xs >- merge(2)
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
        
        let res = scheduler.start {
            xs >- merge(2)
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
        
        let res = scheduler.start {
            xs >- merge(3)
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
        
        let res = scheduler.start {
            xs >- merge(3)
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
        
        let res = scheduler.start(450) {
            xs >- merge(2)
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
        
        let res = scheduler.start {
            xs >- merge(2)
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
        
        let res = scheduler.start {
            xs >- merge(2)
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