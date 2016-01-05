//
//  Observable+CreationTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 9/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTests

class ObservableCreationTests : RxTest {
    
}

// MARK: just
extension ObservableCreationTests {
    func testJust_Immediate() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            return Observable.just(42)
        }

        XCTAssertEqual(res.events, [
            next(200, 42),
            completed(200)
            ])
    }

    func testJust_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            return Observable.just(42, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 42),
            completed(202)
            ])
    }

    func testJust_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(200) {
            return Observable.just(42, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            ])
    }

    func testJust_DisposeAfterNext() {
        let scheduler = TestScheduler(initialClock: 0)

        let d = SingleAssignmentDisposable()

        let res = scheduler.createObserver(Int)

        scheduler.scheduleAt(100) {
            d.disposable = Observable.just(42, scheduler: scheduler).subscribe { e in
                res.on(e)

                switch e {
                case .Next:
                    d.dispose()
                default:
                    break
                }
            }
        }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(101, 42)
            ])
    }

    func testJust_DefaultScheduler() {
        let res = try! Observable.just(42, scheduler: MainScheduler.instance)
            .toBlocking()
            .toArray()

        XCTAssertEqual(res, [
            42
            ])
    }
}

// MARK: toObservable
extension ObservableCreationTests {
    func testToObservable_complete_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            [3, 1, 2, 4].toObservable()
        }

        XCTAssertEqual(res.events, [
            next(200, 3),
            next(200, 1),
            next(200, 2),
            next(200, 4),
            completed(200)
            ])
    }

    func testToObservable_complete() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            [3, 1, 2, 4].toObservable(scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            next(203, 2),
            next(204, 4),
            completed(205)
            ])
    }

    func testToObservable_dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start(203) {
            [3, 1, 2, 4].toObservable(scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            ])
    }
}

// MARK: sequenceOf
extension ObservableCreationTests {
    func testSequenceOf_complete_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.of(3, 1, 2, 4)
        }

        XCTAssertEqual(res.events, [
            next(200, 3),
            next(200, 1),
            next(200, 2),
            next(200, 4),
            completed(200)
            ])
    }

    func testSequenceOf_complete() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.of(3, 1, 2, 4, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            next(203, 2),
            next(204, 4),
            completed(205)
            ])
    }

    func testSequenceOf_dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start(203) {
            Observable.of(3, 1, 2, 4, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            ])
    }
}

// MARK: toObservable 
extension ObservableCreationTests {
    func testToObservableAnySequence_basic_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            AnySequence([3, 1, 2, 4]).toObservable()
        }

        XCTAssertEqual(res.events, [
            next(200, 3),
            next(200, 1),
            next(200, 2),
            next(200, 4),
            completed(200)
            ])
    }

    func testToObservableAnySequence_basic_testScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            AnySequence([3, 1, 2, 4]).toObservable(scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            next(203, 2),
            next(204, 4),
            completed(205)
            ])
    }
}

// MARK: generate
extension ObservableCreationTests {
    func testGenerate_Finite() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            Observable.generate(initialState: 0, condition: { x in x <= 3 }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.events, [
            next(201, 0),
            next(202, 1),
            next(203, 2),
            next(204, 3),
            completed(205)
            ])
        
    }
    
    func testGenerate_ThrowCondition() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            Observable.generate(initialState: 0, condition: { _ in throw testError }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.events, [
            error(201, testError)
            ])
        
    }
    
    func testGenerate_ThrowIterate() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            Observable.generate(initialState: 0, condition: { _ in true }, scheduler: scheduler) { (_: Int) -> Int in
                throw testError
            }
        }
        
        XCTAssertEqual(res.events, [
            next(201, 0),
            error(202, testError)
            ])
        
    }
    
    func testGenerate_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(203) {
            Observable.generate(initialState: 0, condition: { _ in true }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.events, [
            next(201, 0),
            next(202, 1)
            ])
        
    }
    
    func testGenerate_take() {
        var count = 0
    
        var elements = [Int]()
        
        _ = Observable.generate(initialState: 0, condition: { _ in true }) { x in
                count += 1
                return x + 1
            }
            .take(4)
            .subscribe(onNext: { x in
                elements.append(x)
            })
        
        XCTAssertEqual(elements, [0, 1, 2, 3])
        XCTAssertEqual(count, 3)
    }
}

// MARK: range
extension ObservableCreationTests {
    func testRange_Boundaries() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            Observable.range(start: Int.max, count: 1, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(201, Int.max),
            completed(202)
            ])
    }
    
    func testRange_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(204) {
            Observable.range(start: -10, count: 5, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(201, -10),
            next(202, -9),
            next(203, -8)
            ])
    }
}

// MARK: repeatElement
extension ObservableCreationTests {
    func testRepeat_Element() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(207) {
            Observable.repeatElement(42, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(201, 42),
            next(202, 42),
            next(203, 42),
            next(204, 42),
            next(205, 42),
            next(206, 42)
        ])
    }
}

// MARK: using
extension ObservableCreationTests {
    func testUsing_Complete() {
        let scheduler = TestScheduler(initialClock: 0)
       
        var disposeInvoked = 0
        var createInvoked = 0
       
        var xs:TestableObservable<Int>!
        var disposable:MockDisposable!
        var _d:MockDisposable!
        
        let res = scheduler.start {
            Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
                }, observableFactory: { d in
                    _d = d
                    createInvoked += 1
                    xs = scheduler.createColdObservable([
                        next(100, scheduler.clock),
                        completed(200)
                        ])
                    return xs.asObservable()
            }) as Observable<Int>
        }
        
        XCTAssert(disposable === _d)
        
        XCTAssertEqual(res.events, [
            next(300, 200),
            completed(400)
        ])
        
        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(disposable.ticks, [
            200,
            400
            ])
    }
    
    func testUsing_Error() {
        let scheduler = TestScheduler(initialClock: 0)
       
        var disposeInvoked = 0
        var createInvoked = 0
       
        var xs:TestableObservable<Int>!
        var disposable:MockDisposable!
        var _d:MockDisposable!
        
        let res = scheduler.start {
            Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
                }, observableFactory: { d in
                    _d = d
                    createInvoked += 1
                    xs = scheduler.createColdObservable([
                        next(100, scheduler.clock),
                        error(200, testError)
                        ])
                    return xs.asObservable()
            }) as Observable<Int>
        }
        
        XCTAssert(disposable === _d)
        
        XCTAssertEqual(res.events, [
            next(300, 200),
            error(400, testError)
        ])
        
        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(disposable.ticks, [
            200,
            400
            ])
    }
    
    func testUsing_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
       
        var disposeInvoked = 0
        var createInvoked = 0
       
        var xs:TestableObservable<Int>!
        var disposable:MockDisposable!
        var _d:MockDisposable!
        
        let res = scheduler.start {
            Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
                }, observableFactory: { d in
                    _d = d
                    createInvoked += 1
                    xs = scheduler.createColdObservable([
                        next(100, scheduler.clock),
                        next(1000, scheduler.clock + 1)
                        ])
                    return xs.asObservable()
            }) as Observable<Int>
        }
        
        XCTAssert(disposable === _d)
        
        XCTAssertEqual(res.events, [
            next(300, 200),
        ])
        
        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(disposable.ticks, [
            200,
            1000
            ])
    }
    
    func testUsing_ThrowResourceSelector() {
        let scheduler = TestScheduler(initialClock: 0)
       
        var disposeInvoked = 0
        var createInvoked = 0
       
        let res = scheduler.start {
            Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                throw testError
                }, observableFactory: { d in
                    createInvoked += 1
                    return Observable.never()
                    
            }) as Observable<Int>
        }
        
        XCTAssertEqual(res.events, [
            error(200, testError),
        ])
        
        XCTAssertEqual(0, createInvoked)
        XCTAssertEqual(1, disposeInvoked)
    }
    
    func testUsing_ThrowResourceUsage() {
        let scheduler = TestScheduler(initialClock: 0)
       
        var disposeInvoked = 0
        var createInvoked = 0
        var disposable:MockDisposable!
       
        let res = scheduler.start {
            Observable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
                }, observableFactory: { d in
                    createInvoked += 1
                    throw testError
                    
            }) as Observable<Int>
        }
        
        XCTAssertEqual(res.events, [
            error(200, testError),
        ])
        
        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)
        
        XCTAssertEqual(disposable.ticks, [
            200,
            200
            ])
    }
}