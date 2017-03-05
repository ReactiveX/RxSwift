//
//  Observable+CreationTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 9/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

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

        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(100) {
            let subscription = Observable.just(42, scheduler: scheduler).subscribe { e in
                res.on(e)

                switch e {
                case .next:
                    d.dispose()
                default:
                    break
                }
            }

            d.setDisposable(subscription)
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

    func testJust_CompilesInMap() {
        _ = (1 as Int?).map(Observable.just)
    }

    #if TRACE_RESOURCES
        func testJustReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).subscribe()
        }
    #endif

    #if TRACE_RESOURCES
        func testJustSchdedulerReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }
    #endif
}

// MARK: from
extension ObservableCreationTests {
    func testFromArray_complete_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from([3, 1, 2, 4], scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            next(203, 2),
            next(204, 4),
            completed(205)
            ])
    }

    func testFromArray_complete() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from([3, 1, 2, 4], scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            next(203, 2),
            next(204, 4),
            completed(205)
            ])
    }

    func testFromArray_dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start(203) {
            Observable.from([3, 1, 2, 4], scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            ])
    }

    #if TRACE_RESOURCES
        func testFromArrayReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable.from([1], scheduler: testScheduler).subscribe()
            testScheduler.start()
        }
    #endif
}

// MARK: of
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

    #if TRACE_RESOURCES
        func testOfReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.of(11, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }
    #endif
}

// MARK: fromSequence
extension ObservableCreationTests {
    func testFromAnySequence_basic_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(AnySequence([3, 1, 2, 4]), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            next(203, 2),
            next(204, 4),
            completed(205)
            ])
    }

    func testToObservableAnySequence_basic_testScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(AnySequence([3, 1, 2, 4]), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 3),
            next(202, 1),
            next(203, 2),
            next(204, 4),
            completed(205)
            ])
    }

    #if TRACE_RESOURCES
        func testFromSequenceReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.from(AnySequence([3, 1, 2, 4]), scheduler: testScheduler).subscribe()
            testScheduler.start()
        }
    #endif
}

// from optional
extension ObservableCreationTests {
    func testToObservableOptionalSome_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.some(5))
        }
        
        XCTAssertEqual(res.events, [
            next(200, 5),
            completed(200)
            ])
    }
    
    func testToObservableOptionalNone_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.none)
        }
        
        XCTAssertEqual(res.events, [
            completed(200)
            ])
    }

    func testToObservableOptionalSome_basic_testScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.some(5), scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            next(201, 5),
            completed(202)
            ])
    }

    func testToObservableOptionalNone_basic_testScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.none, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            completed(201)
            ])
    }

    #if TRACE_RESOURCES
        func testFromOptionalScheduler1ReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.from(optional: 1 as Int?, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }

        func testFromOptionalScheduler2ReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.from(optional: nil as Int?, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }

        func testFromOptional1ReleasesResourcesOnComplete() {
            _ = Observable<Int>.from(optional: 1 as Int?).subscribe()
        }

        func testFromOptional2ReleasesResourcesOnComplete() {
            _ = Observable<Int>.from(optional: nil as Int?).subscribe()
        }
    #endif
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

    #if TRACE_RESOURCES
        func testGenerateReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.generate(initialState: 0, condition: { _ in false }, scheduler: testScheduler) { (x: Int) -> Int in
                return x
            }.subscribe()
            testScheduler.start()
        }

        func testGenerateReleasesResourcesOnError() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.generate(initialState: 0, condition: { _ in false }, scheduler: testScheduler) { (x: Int) -> Int in
                throw testError
            }.subscribe()
            testScheduler.start()
        }
    #endif
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

    #if TRACE_RESOURCES
        func testRangeSchedulerReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.range(start: 0, count: 1, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }

        func testRangeReleasesResourcesOnComplete() {
            _ = Observable<Int>.range(start: 0, count: 1).subscribe()
        }
    #endif
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

    #if TRACE_RESOURCES
        func testUsingReleasesResourcesOnComplete() {
            let compositeDisposable = CompositeDisposable(disposables: [])
            _ = Observable<Int>.using({ _ in compositeDisposable} , observableFactory: { _ in Observable<Int>.just(1) }).subscribe()
        }

        func testUsingReleasesResourcesOnError() {
            let compositeDisposable = CompositeDisposable(disposables: [])
            _ = Observable<Int>.using({ _ in compositeDisposable} , observableFactory: { _ in Observable<Int>.error(testError) }).subscribe()
        }
    #endif
}
