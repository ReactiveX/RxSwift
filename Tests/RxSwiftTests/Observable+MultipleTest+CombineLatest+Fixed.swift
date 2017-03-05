//
//  Observable+MultipleTest+CombineLatest+Fixed.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/4/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

extension ObservableMultipleTest {
    func testCombineLatest_NeverEmpty() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                next(150, 1)
            ])

            let e1 = scheduler.createHotObservable([
                next(150, 1),
                completed(210)
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
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let e0 = scheduler.createHotObservable([
                next(150, 1),
                completed(210)
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1)
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
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [completed(215)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 210)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 215)])
        }
    }
    
    func testCombineLatest_ReturnEmpty() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [completed(215)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 215)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
        }
    }
    
    func testCombineLatest_NeverReturn() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [next(220, (2 + 3)), completed(240)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 240)])
        }
    }

    func testCombineLatest_ReturnReturn2() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [next(220, (2 + 3)), completed(240)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 240)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_EmptyError() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                 factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ErrorEmpty() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ReturnThrow() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowReturn() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowThrow1() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError1)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowThrow2() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError2)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ErrorThrow() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError1)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowError() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError1)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_SomeThrow() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowSome() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(220, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_ThrowAfterCompleteLeft() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(230, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 220)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_ThrowAfterCompleteRight() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(230, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 220)])
        }
    }
    
    func testCombineLatest_TestInterleavedWithTail() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            let messages = [
                next(220, 2 + 3),
                next(225, 3 + 4),
                next(230, 4 + 5),
                next(235, 4 + 6),
                next(240, 4 + 7),
                completed(250)
            ]
            
            XCTAssertEqual(res.events, messages)
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testCombineLatest_Consecutive() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            let messages = [
                next(235, 4 + 6),
                next(240, 4 + 7),
                completed(250)
            ]
            
            XCTAssertEqual(res.events, messages)
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testCombineLatest_ConsecutiveEndWithErrorLeft() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [error(230, testError)])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 230)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 230)])
        }
    }
    
    func testCombineLatest_ConsecutiveEndWithErrorRight() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.combineLatest(e0, e1) { (x1, x2) in x1 + x2 } },
                { e0, e1 in Observable.combineLatest(e0, e1).map { (x1, x2) in x1 + x2 } },
            ]

        for factory in factories {
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
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                next(235, 4 + 6),
                next(240, 4 + 7),
                error(245, testError)
                ])
            
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
