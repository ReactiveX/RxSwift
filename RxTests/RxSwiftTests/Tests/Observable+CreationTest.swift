//
//  Observable+CreationTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 9/2/15.
//
//

import Foundation
import XCTest
import RxSwift

class ObservableCreationTests : RxTest {
    
}

// MARK: just
extension ObservableCreationTests {
    func testJust_Immediate() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            return just(42)
        }

        XCTAssertEqual(res.messages, [
            next(200, 42),
            completed(200)
            ])
    }

    func testJust_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            return just(42, scheduler: scheduler)
        }

        XCTAssertEqual(res.messages, [
            next(201, 42),
            completed(202)
            ])
    }

    func testJust_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(200) {
            return just(42, scheduler: scheduler)
        }

        XCTAssertEqual(res.messages, [
            ])
    }

    func testJust_DisposeAfterNext() {
        let scheduler = TestScheduler(initialClock: 0)

        let d = SingleAssignmentDisposable()

        let res = createObserver(scheduler) as MockObserver<Int>

        scheduler.scheduleAt(100) {
            d.disposable = just(42, scheduler: scheduler).subscribe { e in
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

        XCTAssertEqual(res.messages, [
            next(101, 42)
            ])
    }

    func testJust_DefaultScheduler() {
        let res = try! just(42, scheduler: MainScheduler.sharedInstance)
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

        XCTAssertEqual(res.messages, [
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

        XCTAssertEqual(res.messages, [
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

        XCTAssertEqual(res.messages, [
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
            sequenceOf(3, 1, 2, 4)
        }

        XCTAssertEqual(res.messages, [
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
            sequenceOf(3, 1, 2, 4, scheduler: scheduler)
        }

        XCTAssertEqual(res.messages, [
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
            sequenceOf(3, 1, 2, 4, scheduler: scheduler)
        }

        XCTAssertEqual(res.messages, [
            next(201, 3),
            next(202, 1),
            ])
    }
}

// MARK: generate
extension ObservableCreationTests {
    func testGenerate_Finite() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            generate(0, condition: { x in x <= 3 }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.messages, [
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
            generate(0, condition: { _ in throw testError }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.messages, [
            error(201, testError)
            ])
        
    }
    
    func testGenerate_ThrowIterate() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            generate(0, condition: { _ in true }, scheduler: scheduler) { (_: Int) -> Int in
                throw testError
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(201, 0),
            error(202, testError)
            ])
        
    }
    
    func testGenerate_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(203) {
            generate(0, condition: { _ in true }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(201, 0),
            next(202, 1)
            ])
        
    }
    
    func testGenerate_take() {
        var count = 0
    
        var elements = [Int]()
        
        _ = generate(0, condition: { _ in true }) { x in
                count++
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
            range(Int.max, 1, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(201, Int.max),
            completed(202)
            ])
    }
    
    func testRange_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(204) {
            range(-10, 5, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
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
            repeatElement(42, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
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
       
        var xs:ColdObservable<Int>!
        var disposable:MockDisposable!
        var _d:MockDisposable!
        
        let res = scheduler.start {
            using({ () -> MockDisposable in
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
        
        XCTAssertEqual(res.messages, [
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
       
        var xs:ColdObservable<Int>!
        var disposable:MockDisposable!
        var _d:MockDisposable!
        
        let res = scheduler.start {
            using({ () -> MockDisposable in
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
        
        XCTAssertEqual(res.messages, [
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
       
        var xs:ColdObservable<Int>!
        var disposable:MockDisposable!
        var _d:MockDisposable!
        
        let res = scheduler.start {
            using({ () -> MockDisposable in
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
        
        XCTAssertEqual(res.messages, [
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
            using({ () -> MockDisposable in
                disposeInvoked += 1
                throw testError
                }, observableFactory: { d in
                    createInvoked += 1
                    return never()
                    
            }) as Observable<Int>
        }
        
        XCTAssertEqual(res.messages, [
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
            using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
                }, observableFactory: { d in
                    createInvoked += 1
                    throw testError
                    
            }) as Observable<Int>
        }
        
        XCTAssertEqual(res.messages, [
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