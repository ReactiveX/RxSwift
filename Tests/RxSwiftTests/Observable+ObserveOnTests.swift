//
//  Observable+ObserveOnTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest

import class Foundation.NSLock
import class Foundation.NSError
import class Foundation.NSCondition
import class Foundation.OperationQueue
import class Foundation.Thread

class ObservableObserveOnTestBase : RxTest {
    var lock = NSLock()

    func performLocked(_ action: () -> Void) {
        lock.lock()
        action()
        lock.unlock()
    }

    override func tearDown() {
        super.tearDown()
    }
}

class ObservableObserveOnTest : ObservableObserveOnTestBase {
}

// observeOn serial scheduler
extension ObservableObserveOnTest {

    func runDispatchQueueSchedulerTests(_ tests: (SerialDispatchQueueScheduler) -> Disposable) {
        let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "testQueue1")
        runDispatchQueueSchedulerTests(scheduler, tests: tests).dispose()
    }

    func runDispatchQueueSchedulerTests(_ scheduler: SerialDispatchQueueScheduler, tests: (SerialDispatchQueueScheduler) -> Disposable) -> Disposable {
        // simplest possible solution, even though it has horrible efficiency in this case probably
        let disposable = tests(scheduler)
        let expectation = self.expectation(description: "Wait for all tests to complete")

        _ = scheduler.schedule(()) { s in
            expectation.fulfill()
            return Disposables.create()
        }

        waitForExpectations(timeout: 1.0) { e in
            XCTAssertTrue(e == nil, "Everything not completed in 1.0 sec.")
        }

        return disposable
    }

    func runDispatchQueueSchedulerMultiplexedTests(_ tests: [(SerialDispatchQueueScheduler) -> Disposable]) {
        let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "testQueue1")

        let compositeDisposable = CompositeDisposable()

        for test in tests {
            _ = compositeDisposable.insert(runDispatchQueueSchedulerTests(scheduler, tests: test))
        }

        compositeDisposable.dispose()
    }

    // tests

    func testObserveOnDispatchQueue_DoesPerformWorkOnQueue() {
        let unitTestsThread = Thread.current

        var didExecute = false

        runDispatchQueueSchedulerTests { scheduler in
            let observable = Observable.just(0)
                .observeOn(scheduler)
            return observable.subscribe(onNext: { n in
                didExecute = true
                XCTAssert(Thread.current !== unitTestsThread)
            })
        }

        XCTAssert(didExecute)
    }

    #if TRACE_RESOURCES
        func testObserveOnDispatchQueue_EnsureCorrectImplementationIsChosen() {
            runDispatchQueueSchedulerTests { scheduler in
                XCTAssert(Resources.numberOfSerialDispatchQueueObservables == 0)
                let a = Observable.just(0)
                .observeOn(scheduler)
                XCTAssertTrue(a == a) // shut up swift compiler :(, we only need to keep this in memory
                XCTAssert(Resources.numberOfSerialDispatchQueueObservables == 1)
                return Disposables.create()
            }

            XCTAssert(Resources.numberOfSerialDispatchQueueObservables == 0)
        }

        func testObserveOnDispatchQueue_DispatchQueueSchedulerIsSerial() {
            var numberOfConcurrentEvents = AtomicInt(0)
            var numberOfExecutions = AtomicInt(0)
            runDispatchQueueSchedulerTests { scheduler in
                XCTAssert(Resources.numberOfSerialDispatchQueueObservables == 0)
                let action = { (s: Void) -> Disposable in
                    XCTAssertEqual(numberOfConcurrentEvents.increment(), 0)
                    self.sleep(0.1) // should be enough to block the queue, so if it's concurrent, it will fail
                    XCTAssertEqual(numberOfConcurrentEvents.decrement(), 1)
                    numberOfExecutions.increment()
                    return Disposables.create()
                }
                _ = scheduler.schedule((), action: action)
                _ = scheduler.schedule((), action: action)
                return Disposables.create()
            }

            XCTAssertEqual(Resources.numberOfSerialDispatchQueueObservables, 0)
            XCTAssertEqual(numberOfExecutions.load(), 2)
        }
    #endif

    func testObserveOnDispatchQueue_DeadlockErrorImmediately() {
        var nEvents = 0

        runDispatchQueueSchedulerTests { scheduler in
            let observable: Observable<Int> = Observable.error(testError).observeOn(scheduler)
            return observable.subscribe(onError: { n in
                nEvents += 1
            })
        }

        XCTAssertEqual(nEvents, 1)
    }

    func testObserveOnDispatchQueue_DeadlockEmpty() {
        var nEvents = 0

        runDispatchQueueSchedulerTests { scheduler in
            let observable: Observable<Int> = Observable.empty().observeOn(scheduler)

            return observable.subscribe(onCompleted: {
                nEvents += 1
            })
        }

        XCTAssertEqual(nEvents, 1)
    }

    func testObserveOnDispatchQueue_Never() {
        runDispatchQueueSchedulerTests { scheduler in
            let xs: Observable<Int> = Observable.never()
            return xs
                .observeOn(scheduler)
                .subscribe(onNext: { n in
                    XCTAssert(false)
                })
        }
    }

    func testObserveOnDispatchQueue_Simple() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                let subscription = (xs.observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                xs.on(.next(0))

                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0)
                    ])
                xs.on(.next(1))
                xs.on(.next(2))
                return Disposables.create()
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0),
                    .next(1),
                    .next(2)
                    ])
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                xs.on(.completed)
                return Disposables.create()
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0),
                    .next(1),
                    .next(2),
                    .completed()
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return Disposables.create()
            },
            ])
    }

    func testObserveOnDispatchQueue_Empty() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                let subscription = (xs.observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                xs.on(.completed)
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .completed()
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return Disposables.create()
            }
            ])
    }

    func testObserveOnDispatchQueue_Error() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                let subscription = (xs.observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                xs.on(.next(0))

                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0)
                    ])
                xs.on(.next(1))
                xs.on(.next(2))
                return Disposables.create()
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0),
                    .next(1),
                    .next(2)
                    ])
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                xs.on(.error(testError))
                return Disposables.create()
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0),
                    .next(1),
                    .next(2),
                    .error(testError)
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return Disposables.create()
            },
            ])
    }

    func testObserveOnDispatchQueue_Dispose() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        var subscription: Disposable!

        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                subscription = (xs.observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                xs.on(.next(0))

                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0)
                    ])

                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                subscription.dispose()
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])

                xs.on(.error(testError))

                return Disposables.create()
            },
            { scheduler in
                XCTAssertEqual(observer.events, [
                    .next(0),
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return Disposables.create()
            }
            ])
    }

    #if TRACE_RESOURCES
        func testObserveOnSerialReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).observeOn(MainScheduler.instance).subscribe()
        }

        func testObserveOnSerialReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).observeOn(MainScheduler.instance).subscribe()
        }
    #endif
}

// Because of `self.wait(for: [blockingTheSerialScheduler], timeout: 1.0)`.
// Testing this on Unix should be enough.
#if !os(Linux)
// Test event is cancelled properly.
extension ObservableObserveOnTest {
    func testDisposeWithEnqueuedElement() {
        let emit = PublishSubject<Int>()
        let blockingTheSerialScheduler = self.expectation(description: "blocking")
        let unblock = self.expectation(description: "unblock")
        let testDone = self.expectation(description: "test done")
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        var events: [Event<Int>] = []
        let subscription = emit.observeOn(scheduler).subscribe { update in
            switch update {
            case .next(let value):
                if value == 0 {
                    blockingTheSerialScheduler.fulfill()
                    self.wait(for: [unblock], timeout: 1.0)
                }
            default:
                break
            }
            events.append(update)
        }
        emit.on(.next(0))
        self.wait(for: [blockingTheSerialScheduler], timeout: 1.0)
        emit.on(.next(1))
        _ = scheduler.schedule(()) { _ in
            testDone.fulfill()
            return Disposables.create()
        }
        subscription.dispose()
        unblock.fulfill()
        self.wait(for: [testDone], timeout: 1.0)
        XCTAssertEqual(events, [.next(0)])
    }

    func testDisposeWithEnqueuedError() {
        let emit = PublishSubject<Int>()
        let blockingTheSerialScheduler = self.expectation(description: "blocking")
        let unblock = self.expectation(description: "unblock")
        let testDone = self.expectation(description: "test done")
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        var events: [Event<Int>] = []
        let subscription = emit.observeOn(scheduler).subscribe { update in
            switch update {
            case .next(let value):
                if value == 0 {
                    blockingTheSerialScheduler.fulfill()
                    self.wait(for: [unblock], timeout: 1.0)
                }
            default:
                break
            }
            events.append(update)
        }
        emit.on(.next(0))
        self.wait(for: [blockingTheSerialScheduler], timeout: 1.0)
        emit.on(.error(TestError.dummyError))
        _ = scheduler.schedule(()) { _ in
            testDone.fulfill()
            return Disposables.create()
        }
        subscription.dispose()
        unblock.fulfill()
        self.wait(for: [testDone], timeout: 1.0)
        XCTAssertEqual(events, [.next(0)])
    }

    func testDisposeWithEnqueuedCompleted() {
        let emit = PublishSubject<Int>()
        let blockingTheSerialScheduler = self.expectation(description: "blocking")
        let unblock = self.expectation(description: "unblock")
        let testDone = self.expectation(description: "test done")
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        var events: [Event<Int>] = []
        let subscription = emit.observeOn(scheduler).subscribe { update in
            switch update {
            case .next(let value):
                if value == 0 {
                    blockingTheSerialScheduler.fulfill()
                    self.wait(for: [unblock], timeout: 1.0)
                }
            default:
                break
            }
            events.append(update)
        }
        emit.on(.next(0))
        self.wait(for: [blockingTheSerialScheduler], timeout: 1.0)
        emit.on(.completed)
        _ = scheduler.schedule(()) { _ in
            testDone.fulfill()
            return Disposables.create()
        }
        subscription.dispose()
        unblock.fulfill()
        self.wait(for: [testDone], timeout: 1.0)
        XCTAssertEqual(events, [.next(0)])
    }
}
#endif

// observeOn concurrent scheduler
class ObservableObserveOnTestConcurrentSchedulerTest: ObservableObserveOnTestBase {

    func createScheduler() -> ImmediateSchedulerType {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 8
        return OperationQueueScheduler(operationQueue: operationQueue)
    }

    #if TRACE_RESOURCES
        func testObserveOn_EnsureCorrectImplementationIsChosen() {
            let scheduler = self.createScheduler()

            XCTAssert(Resources.numberOfSerialDispatchQueueObservables == 0)
            _ = Observable.just(0).observeOn(scheduler)
            self.sleep(0.1)
            XCTAssert(Resources.numberOfSerialDispatchQueueObservables == 0)
        }
    #endif

    func testObserveOn_EnsureTestsAreExecutedWithRealConcurrentScheduler() {
        var events: [String] = []

        let stop = BehaviorSubject(value: 0)

        let scheduler = createScheduler()

        let condition = NSCondition()

        var writtenStarted = 0
        var writtenEnded = 0

        let concurrent = { () -> Disposable in
            self.performLocked {
                events.append("Started")
            }

            condition.lock()
            writtenStarted += 1
            condition.signal()
            while writtenStarted < 2 {
                condition.wait()
            }
            condition.unlock()

            self.performLocked {
                events.append("Ended")
            }

            condition.lock()
            writtenEnded += 1
            condition.signal()
            while writtenEnded < 2 {
                condition.wait()
            }
            condition.unlock()

            stop.on(.completed)

            return Disposables.create()
        }

        _ = scheduler.schedule((), action: concurrent)

        _ = scheduler.schedule((), action: concurrent)

        _ = try! stop.toBlocking().last()

        XCTAssertEqual(events, ["Started", "Started", "Ended", "Ended"])
    }

    func testObserveOn_Never() {
        let scheduler = createScheduler()

        let xs: Observable<Int> = Observable.never()
        let subscription = xs
            .observeOn(scheduler)
            .subscribe(onNext: { n in
                XCTAssert(false)
            })

        sleep(0.1)

        subscription.dispose()
    }

    func testObserveOn_Simple() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        let scheduler = createScheduler()

        let subscription = (xs.observeOn(scheduler)).subscribe(observer)
        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        xs.on(.next(0))

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0)
            ])
        xs.on(.next(1))
        xs.on(.next(2))

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0),
            .next(1),
            .next(2)
            ])
        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        xs.on(.completed)

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0),
            .next(1),
            .next(2),
            .completed()
            ])
        XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])

        subscription.dispose()

        sleep(0.1)
    }

    func testObserveOn_Empty() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        let scheduler = createScheduler()

        _ = xs.observeOn(scheduler).subscribe(observer)

        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        xs.on(.completed)

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .completed()
            ])
        XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
    }

    func testObserveOn_ConcurrentSchedulerIsSerialized() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        var executed = false

        let scheduler = createScheduler()

        let res = xs
            .observeOn(scheduler)
            .map { v -> Int in
                if v == 0 {
                    self.sleep(0.1) // 100 ms is enough
                    executed = true
                }
                return v
        }
        let subscription = res.subscribe(observer)

        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        xs.on(.next(0))
        xs.on(.next(1))
        xs.on(.completed)

        sleep(0.3)

        XCTAssertEqual(observer.events, [
            .next(0),
            .next(1),
            .completed()
            ])
        XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])

        XCTAssert(executed)

        subscription.dispose()
    }

    func testObserveOn_Error() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        let scheduler = createScheduler()

        _ = xs.observeOn(scheduler).subscribe(observer)

        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        xs.on(.next(0))

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0)
            ])
        xs.on(.next(1))
        xs.on(.next(2))

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0),
            .next(1),
            .next(2)
            ])
        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        xs.on(.error(testError))

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0),
            .next(1),
            .next(2),
            .error(testError)
            ])
        XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])

    }

    func testObserveOn_Dispose() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()

        let scheduler = createScheduler()
        let subscription = xs.observeOn(scheduler).subscribe(observer)
        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        xs.on(.next(0))

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0)
            ])

        XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
        subscription.dispose()
        XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])

        xs.on(.error(testError))

        sleep(0.1)

        XCTAssertEqual(observer.events, [
            .next(0),
            ])
        XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
    }

    #if TRACE_RESOURCES
        func testObserveOnReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).observeOn(testScheduler).subscribe()
            testScheduler.start()
        }
        
        func testObserveOnReleasesResourcesOnError() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).observeOn(testScheduler).subscribe()
            testScheduler.start()
        }
    #endif
}

final class ObservableObserveOnTestConcurrentSchedulerTest2 : ObservableObserveOnTestConcurrentSchedulerTest {
    override func createScheduler() -> ImmediateSchedulerType {
        return ConcurrentDispatchQueueScheduler(qos: .default)
    }
}
