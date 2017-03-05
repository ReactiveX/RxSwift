//
//  Observable+MultipleTest3.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

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
            Observable.amb([x1, x2, x3].map { $0.asObservable() })
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

    #if TRACE_RESOURCES
        func testAmb1ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).delay(10, scheduler: scheduler).amb(Observable.just(1)).subscribe()
            scheduler.start()
        }

        func testAmb2ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).amb(Observable.just(1).delay(10, scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testAmb1ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(20, scheduler: scheduler).amb(Observable<Int>.never()).subscribe()
            scheduler.start()
        }

        func testAmb2ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().amb(Observable<Int>.never().timeout(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
}

// MARK: combineLatest + Collection
extension ObservableMultipleTest {
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
                next(150, 1)
            ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1)
            ])
            
            let e2 = scheduler.createHotObservable([
                next(150, 1)
            ])
            
            let res = scheduler.start {
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [])
         
            for e in [e0, e1, e2] {
                XCTAssertEqual(e.subscriptions, [Subscription(200, 1000)])
            }
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
            
            XCTAssertEqual(res.events, [
                completed(215)
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
            
            XCTAssertEqual(res.events, [
                next(220, 2 + 3),
                completed(240)
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
                next(150, 1),
                completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1),
                error(220, testError),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                error(220, testError)
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
                next(150, 1),
                next(210, 2),
                completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1),
                error(220, testError),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                error(220, testError)
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
                next(150, 1),
                error(220, testError1)
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1),
                error(230, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                error(220, testError1)
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
                next(150, 1),
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1),
                error(220, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                error(220, testError2)
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
                next(150, 1),
                next(215, 2),
                completed(230)
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1),
                error(220, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                error(220, testError2)
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
                next(150, 1),
                next(215, 2),
                completed(220)
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1),
                error(230, testError2),
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }
            
            XCTAssertEqual(res.events, [
                error(230, testError2)
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
            
            XCTAssertEqual(res.events, [
                next(235, 4 + 6),
                next(240, 4 + 7),
                completed(250)
                ])
            
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
            
            XCTAssertEqual(res.events, [
                error(230, testError)
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
            Observable.combineLatest([e0, e1].map { $0.asObservable() }) { x throws -> Int in throw testError }
        }
        
        XCTAssertEqual(res.events, [
            error(220, testError)
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
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                completed(500)
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
                factory(e0, e1, e2)
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
                factory(e0, e1, e2)
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
                factory(e0, e1, e2)
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

// MARK: zip + Collection
extension ObservableMultipleTest {
    func testZip_NAry_symmetric() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in Observable.zip([e0, e1, e2].map { $0.asObservable() }) { EquatableArray($0) } },
                { e0, e1, e2 in Observable.zip([e0, e1, e2].map { $0.asObservable() }).map { EquatableArray($0) } },
            ]

        for factory in factories {
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
                factory(e0, e1, e2)
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
    }
    
    func testZip_NAry_asymmetric() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in Observable.zip([e0, e1, e2].map { $0.asObservable() }) { EquatableArray($0) } },
                { e0, e1, e2 in Observable.zip([e0, e1, e2].map { $0.asObservable() }).map { EquatableArray($0) } },
            ]

        for factory in factories {
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
                factory(e0, e1, e2)
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
    }
    
    func testZip_NAry_error() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>) -> Observable<EquatableArray<Int>>] =
            [
                { e0, e1, e2 in Observable.zip([e0, e1, e2].map { $0.asObservable() }) { EquatableArray($0) } },
                { e0, e1, e2 in Observable.zip([e0, e1, e2].map { $0.asObservable() }).map { EquatableArray($0) } },
            ]

        for factory in factories {
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
                factory(e0, e1, e2)
            }
            
            XCTAssertEqual(res.events, [
                next(230, EquatableArray([1, 2, 3])),
                error(250, testError)
                ])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 250)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 250)])
            XCTAssertEqual(e2.subscriptions, [Subscription(200, 250)])
        }
    }
    
    func testZip_NAry_atLeastOneErrors4() {
        let factories: [(TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>, TestableObservable<Int>)
            -> Observable<Int>] =
            [
                { e0, e1, e2, e3 in Observable.zip([e0, e1, e2, e3].map { $0.asObservable() }) { _ in 42 } },
                { e0, e1, e2, e3 in Observable.zip([e0, e1, e2, e3].map { $0.asObservable() }).map { _ in 42 } },
            ]

        for factory in factories {
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
                factory(e0, e1, e2, e3)
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

    #if TRACE_RESOURCES
        func testZipArrayReleasesResourcesOnComplete1() {
            _ = Observable.zip([Observable.just(1), Observable.just(1)]) { $0.reduce(0, +) }.subscribe()
        }

        func testZipArrayReleasesResourcesOnError1() {
            _ = Observable.zip([Observable<Int>.error(testError), Observable.just(1)]) { $0.reduce(0, +) }.subscribe()
        }

        func testZipArrayReleasesResourcesOnComplete2() {
            _ = Observable.zip([Observable.just(1), Observable.just(1)]).subscribe()
        }

        func testZipArrayReleasesResourcesOnError2() {
            _ = Observable.zip([Observable<Int>.error(testError), Observable.just(1)]).subscribe()
        }
    #endif
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
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 250)
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
            Subscription(200, 250)
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
        
        var isDisposed = false
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r: Observable<Int> = Observable.create { o in
            return Disposables.create {
                isDisposed = true
            }
        }
        
        let res = scheduler.start {
            l.skipUntil(r)
        }
        
        XCTAssertEqual(res.events, [
        ])
        
        XCTAssert(isDisposed, "isDisposed")
    }

    #if TRACE_RESOURCES
        func testSkipUntilReleasesResourcesOnComplete1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delay(20, scheduler: scheduler).skipUntil(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testSkipUntilReleasesResourcesOnComplete2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).skipUntil(Observable<Int>.just(1).delay(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testSkipUntilReleasesResourcesOnError1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(20, scheduler: scheduler).skipUntil(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testSkipUntilReleasesResourcesOnError2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).skipUntil(Observable<Int>.never().timeout(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
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

    #if TRACE_RESOURCES
        func testWithLatestFromReleasesResourcesOnComplete1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delay(20, scheduler: scheduler).withLatestFrom(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testWithLatestFromReleasesResourcesOnComplete2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).withLatestFrom(Observable<Int>.just(1).delay(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testWithLatestFromReleasesResourcesOnError1() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(20, scheduler: scheduler).withLatestFrom(Observable<Int>.just(1)).subscribe()
            scheduler.start()
        }

        func testWithLatestFromReleasesResourcesOnError2() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).withLatestFrom(Observable<Int>.never().timeout(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
}
