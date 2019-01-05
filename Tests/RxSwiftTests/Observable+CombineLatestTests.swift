//
//  Observable+CombineLatestTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/4/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableCombineLatestTest : RxTest {
}

extension ObservableCombineLatestTest {
    func testCombineLatest_NeverEmpty() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1)
            ])

            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(210)
            ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }

            XCTAssertEqual(res.events, [])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
        }
    }
    
    func testCombineLatest_EmptyNever() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(210)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 1000)])
        }
    }
    

    func testCombineLatest_EmptyReturn() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(210)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.completed(215)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 215)])
        }
    }
    
    func testCombineLatest_ReturnEmpty() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(210)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.completed(215)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 215)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
        }
    }
    
    func testCombineLatest_NeverReturn() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 1000)])
        }
    }

    func testCombineLatest_ReturnNever() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ReturnReturn1() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 3),
                .completed(240)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.next(220, (2 + 3)), .completed(240)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 240)])
        }
    }

    func testCombineLatest_ReturnReturn2() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 3),
                .completed(240)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(230)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.next(220, (2 + 3)), .completed(240)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 240)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_EmptyError() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError)
                ])
            
            let res = scheduler.start {
                 factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ErrorEmpty() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(230)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ReturnThrow() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 2),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowReturn() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 2),
                .completed(230)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowThrow1() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError1),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError1)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowThrow2() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError1),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError2)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ErrorThrow() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 2),
                .error(220, testError1),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError1)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowError() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError2),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 2),
                .error(220, testError1),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError1)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_SomeThrow() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowSome() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(230)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowAfterCompleteLeft() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(230, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_ThrowAfterCompleteRight() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(230, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_TestInterleavedWithTail() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 3),
                .next(230, 5),
                .next(235, 6),
                .next(240, 7),
                .completed(250)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }

            let messages = Recorded.events(
                .next(220, 2 + 3),
                .next(225, 3 + 4),
                .next(230, 4 + 5),
                .next(235, 4 + 6),
                .next(240, 4 + 7),
                .completed(250)
            )
            
            XCTAssertEqual(res.events, messages)
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testCombineLatest_Consecutive() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(235, 6),
                .next(240, 7),
                .completed(250)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            let messages = Recorded.events(
                .next(235, 4 + 6),
                .next(240, 4 + 7),
                .completed(250)
            )
            
            XCTAssertEqual(res.events, messages)
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testCombineLatest_ConsecutiveEndWithErrorLeft() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .error(230, testError)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(235, 6),
                .next(240, 7),
                .completed(250)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [.error(230, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_ConsecutiveEndWithErrorRight() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { x1, x2 in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { x1, x2 in x1 + x2 } },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)
            
            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .completed(250)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(235, 6),
                .next(240, 7),
                .error(245, testError)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .next(235, 4 + 6),
                .next(240, 4 + 7),
                .error(245, testError)
                ] as [Recorded<Event<Int>>])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 245)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 245)])
        }
    }

    #if TRACE_RESOURCES
        func testCombineLatestReleasesResourcesOnComplete1() {
            _ = Observable.combineLatest(Observable.just(1), Observable.just(1)).subscribe()
        }

        func testCombineLatestReleasesResourcesOnComplete2() {
            _ = Observable.combineLatest(Observable.just(1), Observable.just(1), resultSelector: +).subscribe()
        }

        func testCombineLatestReleasesResourcesOnError1() {
            _ = Observable.combineLatest(Observable.just(1), Observable<Int>.error(testError)).subscribe()
        }

        func testCombineLatestReleasesResourcesOnError2() {
            _ = Observable.combineLatest(Observable.just(1), Observable.error(testError), resultSelector: +).subscribe()
        }
    #endif
}

extension ObservableCombineLatestTest {

    func testCombineLatest_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = Observable.combineLatest(
            Observable.concat([Observable.of(0, 1, 2), Observable.error(testError)]),
            Observable.of(0, 1, 2)
        ) { $0 + $1 }

        _ = observable.subscribe(onError: { _ in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testCombineLatest_DeadlockErrorImmediately() {
        var nEvents = 0
        
        let observable = Observable.combineLatest(
            Observable.error(testError),
            Observable.of(0, 1, 2)
        ) { $0 + $1 }

        _ = observable.subscribe(onError: { n in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testReplay_DeadlockEmpty() {
        var nEvents = 0
        
        
        let observable = Observable.combineLatest(
            Observable.empty(),
            Observable.of(0, 1, 2)
            ) { $0 + $1 }

        _ = observable.subscribe(onCompleted: {
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }

    #if TRACE_RESOURCES
        func testCombineLatestReleasesResourcesOnComplete() {
            _ = Observable.combineLatest(Observable.just(1), Observable.just(1), resultSelector: +).subscribe()
        }

        func testCombineLatestReleasesResourcesOnError() {
            _ = Observable.combineLatest(Observable.just(1), Observable<Int>.error(testError), resultSelector: +).subscribe()
        }
    #endif
}


extension ObservableCombineLatestTest {
    func testCombineLatest_emptyArrayN() {
        let factories: [() -> Observable<Int>] =
            [
                {
                    Observable<Int>.combineLatest(([] as [Observable<Int>]).map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                {
                    Observable.combineLatest(([] as [Observable<Int>]).map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let res = scheduler.start {
                factory()
            }

            XCTAssertEqual(res.events, [.completed(200, Int.self)])
        }
    }
    
    func testCombineLatest_NeverN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1, e2 in
                    Observable<Int>.combineLatest([e0, e1, e2].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1, e2 in
                    Observable.combineLatest([e0, e1, e2].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)
            
            let e0 = scheduler.createHotObservable([
                .next(150, 1)
            ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1)
            ])
            
            let e2 = scheduler.createHotObservable([
                .next(150, 1)
            ])
            
            let res = scheduler.start {
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [])
         
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 1000)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 1000)])
        }
    }

    func testCombineLatest_NeverEmptyN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(210)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
        }
    }
    
    func testCombineLatest_EmptyNeverN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(210)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 1000)])
        }
    }
    
    func testCombineLatest_EmptyReturnN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(210)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .completed(215)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 215)])
        }
    }
    
    func testCombineLatest_ReturnReturnN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 3),
                .completed(240)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .next(220, 2 + 3),
                .completed(240)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 240)])
        }
    }
    
    func testCombineLatest_EmptyErrorN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .error(220, testError)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ReturnErrorN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 2),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .error(220, testError)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ErrorErrorN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError1)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .error(220, testError1)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_NeverErrorN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .error(220, testError2)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_SomeErrorN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(220, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .error(220, testError2)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ErrorAfterCompletedN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .completed(220)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .error(230, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .error(230, testError2)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_InterleavedWithTailN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 3),
                .next(230, 5),
                .next(235, 6),
                .next(240, 7),
                .completed(250)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .next(220, 2 + 3),
                .next(225, 3 + 4),
                .next(230, 4 + 5),
                .next(235, 4 + 6),
                .next(240, 4 + 7),
                .completed(250)
                ] as [Recorded<Event<Int>>])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testCombineLatest_ConsecutiveN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(235, 6),
                .next(240, 7),
                .completed(250)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .next(235, 4 + 6),
                .next(240, 4 + 7),
                .completed(250)
                ] as [Recorded<Event<Int>>])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testCombineLatest_ConsecutiveNWithErrorLeft() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .error(230, testError)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(235, 6),
                .next(240, 7),
                .completed(250)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .error(230, testError)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_ConsecutiveNWithErrorRight() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in
                    Observable<Int>.combineLatest([e0, e1].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1 in
                    Observable.combineLatest([e0, e1].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(215, 2),
                .next(225, 4),
                .completed(250)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(235, 6),
                .next(240, 7),
                .error(245, testError)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                .next(235, 4 + 6),
                .next(240, 4 + 7),
                .error(245, testError)
                ] as [Recorded<Event<Int>>])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 245)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 245)])
        }
    }
    
    func testCombineLatest_SelectorThrowsN() {
        let scheduler = TestScheduler(initialClock: 0)

        let e0 = scheduler.createHotObservable([
            .next(150, 1),
            .next(215, 2),
            .completed(230)
            ])
        
        let e1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 3),
            .completed(240)
            ])
        
        let res = scheduler.start {
            Observable
                .combineLatest([e0, e1]
                .map { $0.asObservable() }) { _ -> Int in throw testError }
        }
        
        XCTAssertEqual(res.events, [
            .error(220, testError)
        ])
        
        XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
        XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
    }
    
    func testCombineLatest_willNeverBeAbleToCombineN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1, e2 in
                    Observable<Int>.combineLatest([e0, e1, e2].map { $0.asObservable() }).map { _ in 42 }
                },
                { e0, e1, e2 in
                    Observable.combineLatest([e0, e1, e2].map { $0.asObservable() }) { _ in 42 }
                },
            ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(250)
                ])
            
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .completed(260)
                ])
            
            let e2 = scheduler.createHotObservable([
                .next(150, 1),
                .next(500, 2),
                .completed(800)
                ])
            
            let res = scheduler.start {
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                .completed(500)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 250)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 260)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 500)])
        }
    }
    
    func testCombineLatest_typicalN() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1, e2 in
                    Observable<Int>.combineLatest([e0, e1, e2].map { $0.asObservable() }).map { $0.reduce(0, +) }
                },
                { e0, e1, e2 in
                    Observable.combineLatest([e0, e1, e2].map { $0.asObservable() }) { $0.reduce(0, +) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 1),
                .next(410, 4),
                .completed(800)
            ])
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 2),
                .next(420, 5),
                .completed(800)
            ])
            let e2 = scheduler.createHotObservable([
                .next(150, 1),
                .next(230, 3),
                .next(430, 6),
                .completed(800)
            ])
            
            let res = scheduler.start {
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                .next(230, 6),
                .next(410, 9),
                .next(420, 12),
                .next(430, 15),
                .completed(800)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 800)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 800)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 800)])
        }
    }
    
    func testCombineLatest_NAry_symmetric() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in
                    Observable<Int>.combineLatest([e0, e1, e2].map { $0.asObservable() }).map { EquatableArray($0) }
                },
                { e0, e1, e2 in
                    Observable.combineLatest([e0, e1, e2].map { $0.asObservable() }) { EquatableArray($0) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 1),
                .next(250, 4),
                .completed(420)
                ])
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 2),
                .next(240, 5),
                .completed(410)
                ])
            let e2 = scheduler.createHotObservable([
                .next(150, 1),
                .next(230, 3),
                .next(260, 6),
                .completed(400)
                ])
            
            let res = scheduler.start {
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                .next(230, EquatableArray([1, 2, 3])),
                .next(240, EquatableArray([1, 5, 3])),
                .next(250, EquatableArray([4, 5, 3])),
                .next(260, EquatableArray([4, 5, 6])),
                .completed(420)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 420)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 410)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 400)])
        }
    }
    
    func testCombineLatest_NAry_asymmetric() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in
                    Observable<Int>.combineLatest([e0, e1, e2].map { $0.asObservable() }).map { EquatableArray($0) }
                },
                { e0, e1, e2 in
                    Observable.combineLatest([e0, e1, e2].map { $0.asObservable() }) { EquatableArray($0) }
                },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                .next(150, 1),
                .next(210, 1),
                .next(250, 4),
                .completed(270)
                ])
            let e1 = scheduler.createHotObservable([
                .next(150, 1),
                .next(220, 2),
                .next(240, 5),
                .next(290, 7),
                .next(310, 9),
                .completed(410)
                ])
            let e2 = scheduler.createHotObservable([
                .next(150, 1),
                .next(230, 3),
                .next(260, 6),
                .next(280, 8),
                .completed(300)
                ])
            
            let res = scheduler.start {
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                .next(230, EquatableArray([1, 2, 3])),
                .next(240, EquatableArray([1, 5, 3])),
                .next(250, EquatableArray([4, 5, 3])),
                .next(260, EquatableArray([4, 5, 6])),
                .next(280, EquatableArray([4, 5, 8])),
                .next(290, EquatableArray([4, 7, 8])),
                .next(310, EquatableArray([4, 9, 8])),
                .completed(410)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 270)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 410)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 300)])
        }
    }

    #if TRACE_RESOURCES
        func testCombineLatestArrayReleasesResourcesOnComplete1() {
            _ = Observable.combineLatest([Observable.just(1), Observable.just(1)]) { $0.reduce(0, +) }.subscribe()
        }

        func testCombineLatestArrayReleasesResourcesOnError1() {
            _ = Observable.combineLatest([Observable<Int>.error(testError), Observable.just(1)]) { $0.reduce(0, +) }.subscribe()
        }

        func testCombineLatestArrayReleasesResourcesOnComplete2() {
            _ = Observable<Int>.combineLatest([Observable.just(1), Observable.just(1)]).subscribe()
        }

        func testCombineLatestArrayReleasesResourcesOnError2() {
            _ = Observable<Int>.combineLatest([Observable<Int>.error(testError), Observable.just(1)]).subscribe()
        }
    #endif
}
