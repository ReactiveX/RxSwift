//
//  Observable+ConcurrencyTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 5/2/15.
//
//

import Foundation
import XCTest
import RxSwift

class ObservableConcurrencyTest : RxTest {
    var lock = OS_SPINLOCK_INIT
    
    func performLocked(action: () -> Void) {
        OSSpinLockLock(&lock)
        action()
        OSSpinLockUnlock(&lock)
    }
}

// observeSingleOn
extension ObservableConcurrencyTest {
    func testObserveSingleOn_DeadlockSimple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var nEvents = 0
        
        let observable = returnElement(0) >- observeSingleOn(scheduler)
        let _d = observable >- subscribeNext { n in
            nEvents++
        } >- scopedDispose

        scheduler.start()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveSingleOn_DeadlockErrorImmediatelly() {
        let scheduler = TestScheduler(initialClock: 0)

        var nEvents = 0
        
        let observable: Observable<Int> = failWith(testError) >- observeSingleOn(scheduler)
        let _d = observable >- subscribeError { n in
            nEvents++
        } >- scopedDispose
        
        scheduler.start()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveSingleOn_DeadlockEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        var nEvents = 0
        
        let observable: Observable<Int> = empty() >- observeSingleOn(scheduler)
        let _d = observable >- subscribeCompleted {
            nEvents++
        } >- scopedDispose

        scheduler.start()
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveSingleOn_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
            completed(301)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 301)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Simple() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            completed(300)
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
            next(301, 0),
            completed(301)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 301)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(300, testError)
            ])
        
        let res = scheduler.start { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
            error(301, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 301)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testObserveSingleOn_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(290, 0),
            error(300, testError)
            ])
        
        let res = scheduler.start(290) { xs >- observeSingleOn(scheduler) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 290)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}

// observeOn serial scheduler
extension ObservableConcurrencyTest {

    func runDispatchQueueSchedulerTests(tests: (scheduler: DispatchQueueScheduler) -> Disposable) {
        let scheduler = DispatchQueueScheduler(internalSerialQueueName: "testQueue1")
        let _ = runDispatchQueueSchedulerTests(scheduler, tests: tests) >- scopedDispose
    }
    
    func runDispatchQueueSchedulerTests(scheduler: DispatchQueueScheduler, tests: (scheduler: DispatchQueueScheduler) -> Disposable) -> Disposable {
        // simplest possible solution, even though it has horrible efficiency in this case probably
        var wait = OS_SPINLOCK_INIT
        OSSpinLockLock(&wait)

        let disposable = tests(scheduler: scheduler)
        
        scheduler.schedule(()) { s in
            OSSpinLockUnlock(&wait)
            return NopDisposableResult
        }
        
        OSSpinLockLock(&wait)
        
        return disposable
    }
    
    func runDispatchQueueSchedulerMultiplexedTests(tests: [(scheduler: DispatchQueueScheduler) -> Disposable]) {
        let scheduler = DispatchQueueScheduler(internalSerialQueueName: "testQueue1")
        
        let compositeDisposable = CompositeDisposable()
        
        for test in tests {
            compositeDisposable.addDisposable(runDispatchQueueSchedulerTests(scheduler, tests: test))
        }
        
        compositeDisposable.dispose()
    }
    
    // tests
    
    func testObserveOnDispatchQueue_DoesPerformWorkOnQueue() {
        let unitTestsThread = NSThread.currentThread()
        
        var didExecute = false
        
        runDispatchQueueSchedulerTests { scheduler in
            let observable = returnElement(0) >- observeOn(scheduler)
            return observable >- subscribeNext { n in
                didExecute = true
                XCTAssert(NSThread.currentThread() !== unitTestsThread)
            }
        }
        
        XCTAssert(didExecute)
    }
    
    func testObserveOnDispatchQueue_EnsureCorrectImplementationIsChosen() {
        runDispatchQueueSchedulerTests { scheduler in
            XCTAssert(numberOfDispatchQueueObservables == 0)
            let observable = returnElement(0) >- observeOn(scheduler)
            XCTAssert(numberOfDispatchQueueObservables == 1)
            return NopDisposable.instance
        }

        XCTAssert(numberOfDispatchQueueObservables == 0)
    }
    
    func testObserveOnDispatchQueue_DispatchQueueSchedulerIsSerial() {
        var numberOfConcurrentEvents: Int32 = 0
        var numberOfExecutions = 0
        runDispatchQueueSchedulerTests { scheduler in
            XCTAssert(numberOfDispatchQueueObservables == 0)
            return returnElements(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
                >- observeOn(scheduler)
                >- subscribeNext { e in
                    XCTAssert(OSAtomicIncrement32(&numberOfConcurrentEvents) == 1)
                    usleep(1000) // should be enough to block the queue, so if it's concurrent, it will fail
                    XCTAssert(OSAtomicDecrement32(&numberOfConcurrentEvents) == 0)
                    numberOfExecutions++
                }
        }
        
        XCTAssert(numberOfDispatchQueueObservables == 0)
        XCTAssert(numberOfExecutions == 11)
    }
    
    func testObserveOnDispatchQueue_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        runDispatchQueueSchedulerTests { scheduler in
            let observable: Observable<Int> = failWith(testError) >- observeOn(scheduler)
            return observable >- subscribeError { n in
                nEvents++
            }
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveOnDispatchQueue_DeadlockEmpty() {
        var nEvents = 0
        
        runDispatchQueueSchedulerTests { scheduler in
            let observable: Observable<Int> = empty() >- observeOn(scheduler)
            return observable >- subscribeCompleted {
                nEvents++
            }
        }
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testObserveOnDispatchQueue_Never() {
        runDispatchQueueSchedulerTests { scheduler in
            let xs: Observable<Int> = never()
            return xs
                >- observeOn(scheduler)
                >- subscribeNext { n in
                    XCTAssert(false)
                }
        }
    }
    
    func testObserveOnDispatchQueue_Simple() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        
        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                let subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendNext(xs, 0)
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0)
                    ])
                sendNext(xs, 1)
                sendNext(xs, 2)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2)
                    ])
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendCompleted(xs)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2),
                    completed(0)
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            },
            ])
    }
    
    func testObserveOnDispatchQueue_Empty() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        
        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                let subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendCompleted(xs)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    completed()
                ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            }
        ])
    }
    
    func testObserveOnDispatchQueue_Error() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        
        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                let subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendNext(xs, 0)
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0)
                    ])
                sendNext(xs, 1)
                sendNext(xs, 2)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2)
                    ])
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendError(xs, testError)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2),
                    error(testError)
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            },
        ])
    }
    
    func testObserveOnDispatchQueue_Dispose() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        var subscription: Disposable!
        
        runDispatchQueueSchedulerMultiplexedTests([
            { scheduler in
                subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendNext(xs, 0)
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0)
                    ])
                
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                subscription.dispose()
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                
                sendError(xs, testError)
                
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            }
        ])
    }
}

// observeOn concurrent scheduler
extension ObservableConcurrencyTest {
    
    func runConcurentSchedulerTest(test: (scheduler: OperationQueueScheduler) -> Disposable) {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 8
        let scheduler = OperationQueueScheduler(operationQueue: operationQueue)
        let d1 = runConcurentSchedulerTest(scheduler, test: test) >- scopedDispose
    }
    
    func runConcurentSchedulerTest(scheduler: OperationQueueScheduler, test: (scheduler: OperationQueueScheduler) -> Disposable) -> Disposable {
        
        let disposable = test(scheduler: scheduler)
        
        scheduler.operationQueue.waitUntilAllOperationsAreFinished()
        
        return disposable
    }
    
    func runConcurentSchedulerMutiplexedTests(tests: [(scheduler: OperationQueueScheduler) -> Disposable]) {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 8
        let scheduler = OperationQueueScheduler(operationQueue: operationQueue)
        
        let compositeDisposable = CompositeDisposable()
        
        for test in tests {
            compositeDisposable.addDisposable(runConcurentSchedulerTest(scheduler, test: test))
        }
        
        compositeDisposable.dispose()
    }
   
    func testObserveOn_EnsureCorrectImplementationIsChosen() {
        runConcurentSchedulerTest { scheduler in
            XCTAssert(numberOfDispatchQueueObservables == 0)
            let observable = returnElement(0) >- observeOn(scheduler)
            XCTAssert(numberOfDispatchQueueObservables == 0)
            return NopDisposable.instance
        }
        
        XCTAssert(numberOfDispatchQueueObservables == 0)
    }
    
    func testObserveOn_EnsureTestsAreExecutedWithRealConcurrentScheduler() {
        var variable: Int = 0
        
        var events: [String] = []
        
        runConcurentSchedulerTest { scheduler in
            let disposable1 = scheduler.schedule(()) { _ in
                
                self.performLocked {
                    events.append("Started")
                }
                
                while variable != 2 {
                    // to kill compiler optimizations
                    self.performLocked { }
                    if variable == 0 {
                        variable = 1
                    }
                }
                
                self.performLocked {
                    events.append("Ended")
                }
                
                return NopDisposableResult
            }
            
            let disposable2 = scheduler.schedule(()) { _ in
                    //println("variable \(variable)")
                self.performLocked {
                    events.append("Started")
                }
                
                while variable != 2 {
                    // to kill compiler optimizations
                    self.performLocked { }
                    if variable == 1 {
                        variable = 2
                    }
                }
                
                self.performLocked {
                    events.append("Ended")
                }
                
                return NopDisposableResult
            }
            
            return NopDisposable.instance
        }
        
        XCTAssertEqual(events, ["Started", "Started", "Ended", "Ended"])
    }
    
    func testObserveOn_Never() {
        runConcurentSchedulerTest { scheduler in
            let xs: Observable<Int> = never()
            return xs
                >- observeOn(scheduler)
                >- subscribeNext { n in
                    XCTAssert(false)
            }
        }
    }
    
    func testObserveOn_Simple() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        
        runConcurentSchedulerMutiplexedTests([
            { scheduler in
                let subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendNext(xs, 0)
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0)
                    ])
                sendNext(xs, 1)
                sendNext(xs, 2)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2)
                    ])
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendCompleted(xs)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2),
                    completed(0)
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            },
        ])
    }
    
    func testObserveOn_Empty() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        
        runConcurentSchedulerMutiplexedTests([
            { scheduler in
                let subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendCompleted(xs)
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    completed()
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            }
        ])
    }
   
    // It could be maybe written nicer, but the assumptions are reasonable.
    // If first element processing takes 100ms, that should be more then enough
    // for second element to pass by it if operator isn't serializing elements.
    // If that doesn't happen, then it looks like scheduler is serializing
    // processing of elements.
    func testObserveOn_ConcurrentSchedulerIsSerialized() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        
        var executed = false
        
        runConcurentSchedulerMutiplexedTests([
            { scheduler in
                let res = xs
                    >- observeOn(scheduler)
                    >- map { v -> Int in
                        if v == 0 {
                            usleep(100 * 1000) // 100 ms is enough
                            executed = true
                        }
                        return v
                    }
                let subscription = res.subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendNext(xs, 0)
                sendNext(xs, 1)
                sendCompleted(xs)
                
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0, 0),
                    next(0, 1),
                    completed()
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            }
        ])
        
        XCTAssert(executed)
    }
    
    func testObserveOn_Error() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        
        runConcurentSchedulerMutiplexedTests([
            { scheduler in
                let subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendNext(xs, 0)
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0)
                    ])
                sendNext(xs, 1)
                sendNext(xs, 2)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2)
                    ])
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendError(xs, testError)
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    next(1),
                    next(2),
                    error(testError)
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            },
        ])
    }
    
    func testObserveOn_Dispose() {
        let xs = PrimitiveHotObservable<Int>()
        let observer = PrimitiveMockObserver<Int>()
        var subscription: Disposable!
        
        runConcurentSchedulerMutiplexedTests([
            { scheduler in
                subscription = (xs >- observeOn(scheduler)).subscribe(observer)
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                sendNext(xs, 0)
                
                return subscription
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0)
                    ])
                
                XCTAssert(xs.subscriptions == [SubscribedToHotObservable])
                subscription.dispose()
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                
                sendError(xs, testError)
                
                return NopDisposable.instance
            },
            { scheduler in
                XCTAssertEqual(observer.messages, [
                    next(0),
                    ])
                XCTAssert(xs.subscriptions == [UnsunscribedFromHotObservable])
                return NopDisposable.instance
            }
        ])
    }
}

   