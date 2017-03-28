//
//  Observable+SingleTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

import class Foundation.NSError

class ObservableSingleTest : RxTest {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
}

// Creation
extension ObservableSingleTest {
    func testAsObservable_asObservable() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(250)
        ])

        let ys = xs.asObservable()

        XCTAssert(xs !== ys)

        let res = scheduler.start { ys }

        let correct = [
            next(220, 2),
            completed(250)
        ]

        XCTAssertEqual(res.events, correct)
    }

    func testAsObservable_hides() {
        let xs = PrimitiveHotObservable<Int>()

        let res = xs.asObservable()

        XCTAssertTrue(res !== xs)
    }

    func testAsObservable_never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs : Observable<Int> = Observable.never()

        let res = scheduler.start { xs }

        let correct: [Recorded<Event<Int>>] = []

        XCTAssertEqual(res.events, correct)
    }

    #if TRACE_RESOURCES
        func testAsObservableReleasesResourcesOnComplete() {
            _ = Observable<Int>.empty().asObservable().subscribe()
        }

        func testAsObservableReleasesResourcesOnError() {
            _ = Observable<Int>.empty().asObservable().subscribe()
        }
    #endif
}

// Distinct
extension ObservableSingleTest {
    func testDistinctUntilChanged_allChanges() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])

        let res = scheduler.start { xs.distinctUntilChanged { $0 } }

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDistinctUntilChanged_someChanges() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2), // *
            next(215, 3), // *
            next(220, 3),
            next(225, 2), // *
            next(230, 2),
            next(230, 1), // *
            next(240, 2), // *
            completed(250)
            ])


        let res = scheduler.start { xs.distinctUntilChanged { $0 } }

        let correctMessages = [
            next(210, 2),
            next(215, 3),
            next(225, 2),
            next(230, 1),
            next(240, 2),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDistinctUntilChanged_allEqual() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        let res = scheduler.start { xs.distinctUntilChanged { l, r in true } }

        let correctMessages = [
            next(210, 2),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDistinctUntilChanged_allDifferent() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 2),
            next(230, 2),
            next(240, 2),
            completed(250)
            ])

        let res = scheduler.start { xs.distinctUntilChanged({ l, r in false }) }

        let correctMessages = [
            next(210, 2),
            next(220, 2),
            next(230, 2),
            next(240, 2),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDistinctUntilChanged_keySelector_Div2() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 4),
            next(230, 3),
            next(240, 5),
            completed(250)
            ])

        let res = scheduler.start { xs.distinctUntilChanged({ $0 % 2 }) }

        let correctMessages = [
            next(210, 2),
            next(230, 3),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDistinctUntilChanged_keySelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250)
            ])

        let res = scheduler.start { xs.distinctUntilChanged({ _ in throw testError }) }

        let correctMessages = [
            next(210, 2),
            error(220, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 220)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDistinctUntilChanged_comparerThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250)
            ])

        let res = scheduler.start { xs.distinctUntilChanged({ $0 }, comparer: { _, _ in throw testError }) }

        let correctMessages = [
            next(210, 2),
            error(220, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 220)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    #if TRACE_RESOURCES
        func testDistinctUntilChangedReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).distinctUntilChanged().subscribe()
        }

        func testDistinctUntilChangedReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).distinctUntilChanged().subscribe()
        }
    #endif
}

// doOn
extension ObservableSingleTest {
    func testDoOn_shouldSeeAllValues() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var i = 0
        var sum = 2 + 3 + 4 + 5
        let res = scheduler.start { xs.do(onNext: { element in
                i += 1
                sum -= element
            })
        }

        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOn_plainAction() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var i = 0
        let res = scheduler.start { xs.do(onNext: { _ in
                i += 1
            })
        }

        XCTAssertEqual(i, 4)

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOn_nextCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var i = 0
        var sum = 2 + 3 + 4 + 5
        var completedEvaluation = false
        let res = scheduler.start { xs.do(onNext: { value in
                i += 1
                sum -= value
            }, onCompleted: {
                completedEvaluation = true
            })
        }

        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)
        XCTAssertEqual(completedEvaluation, true)

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOn_completedNever() {
        let scheduler = TestScheduler(initialClock: 0)

        let recordedEvents: [Recorded<Event<Int>>] = [
        ]

        let xs = scheduler.createHotObservable(recordedEvents)

        var i = 0
        var completedEvaluation = false
        let res = scheduler.start { xs.do(onNext: { e in
                i += 1
            }, onCompleted: {
                completedEvaluation = true
            })
        }

        XCTAssertEqual(i, 0)
        XCTAssertEqual(completedEvaluation, false)

        let correctMessages: [Recorded<Event<Int>>] = [
        ]

        let correctSubscriptions = [
            Subscription(200, 1000)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOn_nextError() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            error(250, testError)
            ])

        var i = 0
        var sum = 2 + 3 + 4 + 5
        var sawError = false
        let res = scheduler.start { xs.do(onNext: { value in
                i += 1
                sum -= value
            }, onError: { _ in
                sawError = true
            })
        }

        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)
        XCTAssertEqual(sawError, true)

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            error(250, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOn_nextErrorNot() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var i = 0
        var sum = 2 + 3 + 4 + 5
        var sawError = false
        let res = scheduler.start { xs.do(onNext: { value in
                i += 1
                sum -= value
            }, onError: { e in
                sawError = true
            })
        }

        XCTAssertEqual(i, 4)
        XCTAssertEqual(sum, 0)
        XCTAssertEqual(sawError, false)

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOnNext_normal() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var numberOfTimesInvoked = 0

        let res = scheduler.start { xs.do(onNext: { error in
                numberOfTimesInvoked = numberOfTimesInvoked + 1
            })
        }

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(numberOfTimesInvoked, 4)
    }

    func testDoOnNext_throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var numberOfTimesInvoked = 0

        let res = scheduler.start { xs.do(onNext: { error in
                if numberOfTimesInvoked > 2 {
                    throw testError
                }
                numberOfTimesInvoked = numberOfTimesInvoked + 1
            })
        }

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            error(240, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 240)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(numberOfTimesInvoked, 3)
    }

    func testDoOnError_normal() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(250, testError)
            ])

        var recordedError: Swift.Error!
        var numberOfTimesInvoked = 0

        let res = scheduler.start { xs.do(onError: { error in
                recordedError = error
                numberOfTimesInvoked = numberOfTimesInvoked + 1
            })
        }

        let correctMessages = [
            next(210, 2),
            error(250, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(recordedError as! TestError, testError)
        XCTAssertEqual(numberOfTimesInvoked, 1)
    }

    func testDoOnError_throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            error(250, testError)
            ])

        let res = scheduler.start { xs.do(onError: { _ in
                throw testError1
            })
        }

        let correctMessages = [
            next(210, 2),
            error(250, testError1)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func testDoOnCompleted_normal() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        var didComplete = false

        let res = scheduler.start { xs.do(onCompleted: { error in
                didComplete = true
            })
        }

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)

        XCTAssertEqual(didComplete, true)
    }

    func testDoOnCompleted_throws() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        let res = scheduler.start { xs.do(onCompleted: { error in
                throw testError
            })
        }

        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            error(250, testError)
        ]

        let correctSubscriptions = [
            Subscription(200, 250)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    enum DoOnEvent {
        case sourceSubscribe
        case sourceDispose
        case doOnNext
        case doOnCompleted
        case doOnError
        case doOnSubscribe
        case doOnSubscribed
        case doOnDispose
    }

    func testDoOnOrder_Completed_Async() {
        var events = [DoOnEvent]()

        let scheduler = TestScheduler(initialClock: 0)

        _ = scheduler.start {
            Observable<Int>.create { observer in
                    events.append(.sourceSubscribe)
                    scheduler.scheduleAt(300) {
                        observer.on(.next(0))
                        observer.on(.completed)
                    }
                    return Disposables.create {
                        events.append(.sourceDispose)
                    }
                }
                .do(
                    onNext: { _ in events.append(.doOnNext) },
                    onCompleted: { events.append(.doOnCompleted) },
                    onSubscribe: { events.append(.doOnSubscribe) },
                    onSubscribed: { events.append(.doOnSubscribed) },
                    onDispose: { events.append(.doOnDispose) }
                )
        }


        XCTAssertEqual(events, [.doOnSubscribe, .sourceSubscribe, .doOnSubscribed, .doOnNext, .doOnCompleted, .sourceDispose, .doOnDispose])
    }

    func testDoOnOrder_Completed_Sync() {
        var events = [DoOnEvent]()

        let scheduler = TestScheduler(initialClock: 0)

        _ = scheduler.start {
            Observable<Int>.create { observer in
                    events.append(.sourceSubscribe)
                    observer.on(.next(0))
                    observer.on(.completed)
                    return Disposables.create {
                        events.append(.sourceDispose)
                    }
                }
                .do(
                    onNext: { _ in events.append(.doOnNext) },
                    onCompleted: { events.append(.doOnCompleted) },
                    onSubscribe: { events.append(.doOnSubscribe) },
                    onSubscribed: { events.append(.doOnSubscribed) },
                    onDispose: { events.append(.doOnDispose) }
            )
        }


        XCTAssertEqual(events, [.doOnSubscribe, .sourceSubscribe, .doOnNext, .doOnCompleted, .sourceDispose, .doOnSubscribed, .doOnDispose])
    }

    func testDoOnOrder_Error() {
        var events = [DoOnEvent]()

        _ = Observable<Int>.create { observer in
                events.append(.sourceSubscribe)
                observer.on(.next(0))
                observer.on(.error(testError))
                return Disposables.create {
                    events.append(.sourceDispose)
                }
            }
            .do(
                onNext: { _ in events.append(.doOnNext) },
                onError: { _ in events.append(.doOnError) },
                onSubscribe: { events.append(.doOnSubscribe) },
                onSubscribed: { events.append(.doOnSubscribed) },
                onDispose: { events.append(.doOnDispose) }
            )
            .subscribe { _ in }


        XCTAssertEqual(events, [.doOnSubscribe, .sourceSubscribe, .doOnNext, .doOnError, .sourceDispose, .doOnSubscribed, .doOnDispose])
    }

    func testDoOnOrder_Dispose() {
        var events = [DoOnEvent]()

        Observable<Int>.create { observer in
                events.append(.sourceSubscribe)
                observer.on(.next(0))
                return Disposables.create {
                    events.append(.sourceDispose)
                }
            }
            .do(
                onNext: { _ in events.append(.doOnNext) },
                onSubscribe: { events.append(.doOnSubscribe) },
                onSubscribed: { events.append(.doOnSubscribed) },
                onDispose: { events.append(.doOnDispose) }
            )
            .subscribe { _ in }
            .dispose()


        XCTAssertEqual(events, [.doOnSubscribe, .sourceSubscribe, .doOnNext, .doOnSubscribed, .sourceDispose, .doOnDispose])
    }

    #if TRACE_RESOURCES
        func testDoReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).do().subscribe()
        }

        func testDoReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).do().subscribe()
        }
    #endif
}

// retry
extension ObservableSingleTest {
    func testRetry_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            completed(250)
            ])

        let res = scheduler.start {
            xs.retry()
        }

        XCTAssertEqual(res.events, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450)
            ])
    }

    func testRetry_Infinite() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            ])

        let res = scheduler.start {
            xs.retry()
        }

        XCTAssertEqual(res.events, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    func testRetry_Observable_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            error(250, testError),
            ])

        let res = scheduler.start(1100) {
            xs.retry()
        }

        XCTAssertEqual(res.events, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            next(550, 1),
            next(600, 2),
            next(650, 3),
            next(800, 1),
            next(850, 2),
            next(900, 3),
            next(1050, 1)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            Subscription(450, 700),
            Subscription(700, 950),
            Subscription(950, 1100)
            ])
    }

    func testRetryCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(5, 1),
            next(10, 2),
            next(15, 3),
            error(20, testError)
            ])

        let res = scheduler.start {
            xs.retry(3)
        }

        XCTAssertEqual(res.events, [
            next(205, 1),
            next(210, 2),
            next(215, 3),
            next(225, 1),
            next(230, 2),
            next(235, 3),
            next(245, 1),
            next(250, 2),
            next(255, 3),
            error(260, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220),
            Subscription(220, 240),
            Subscription(240, 260)
            ])
    }

    func testRetryCount_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(5, 1),
            next(10, 2),
            next(15, 3),
            error(20, testError)
            ])

        let res = scheduler.start(231) {
            xs.retry(3)
        }

        XCTAssertEqual(res.events, [
            next(205, 1),
            next(210, 2),
            next(215, 3),
            next(225, 1),
            next(230, 2),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220),
            Subscription(220, 231),
            ])
    }

    func testRetryCount_Infinite() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(5, 1),
            next(10, 2),
            next(15, 3),
            error(20, testError)
            ])

        let res = scheduler.start(231) {
            xs.retry(3)
        }

        XCTAssertEqual(res.events, [
            next(205, 1),
            next(210, 2),
            next(215, 3),
            next(225, 1),
            next(230, 2),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220),
            Subscription(220, 231),
            ])
    }

    func testRetryCount_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            completed(250)
            ])

        let res = scheduler.start {
            xs.retry(3)
        }

        XCTAssertEqual(res.events, [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            ])
    }

    func testRetry_tailRecursiveOptimizationsTest() {
        var count = 1
        let sequenceSendingImmediateError: Observable<Int> = Observable.create { observer in
            observer.on(.next(0))
            observer.on(.next(1))
            observer.on(.next(2))
            if count < 2 {
                observer.on(.error(testError))
                count += 1
            }
            observer.on(.next(3))
            observer.on(.next(4))
            observer.on(.next(5))
            observer.on(.completed)

            return Disposables.create()
        }

        _ = sequenceSendingImmediateError
            .retry()
            .subscribe { _ in
            }
    }

    #if TRACE_RESOURCES
        func testRetryReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).retry().subscribe()
        }

        func testRetryReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).retry(1).subscribe()
        }
    #endif
}

struct CustomErrorType : Error {

}

final class RetryWhenError: Error {
    init() {

    }
}

let retryError: RetryWhenError = RetryWhenError()

// retryWhen
extension ObservableSingleTest {

    func testRetryWhen_Never() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])

        let empty = scheduler.createHotObservable([
            next(150, 1),
            completed(210)
            ])

        let res = scheduler.start(300) {
            xs.retryWhen { (errors: Observable<NSError>) in
                return empty
            }
        }

        let correct = [
            completed(250, Int.self)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testRetryWhen_ObservableNever() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            error(250, retryError)
            ])

        let never = scheduler.createHotObservable([
            next(150, 1)
            ])

        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<RetryWhenError>) in
                return never
            }
        }

        let correct = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testRetryWhen_ObservableNeverComplete() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        let never = scheduler.createHotObservable([
            next(150, 1)
            ])

        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<RetryWhenError>) in
                return never
            }
        }

        let correct = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testRetryWhen_ObservableEmpty() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(150, 2),
            next(200, 3),
            completed(250)
            ])

        let empty = scheduler.createHotObservable([
            next(150, 0),
            completed(0)
            ])

        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<RetryWhenError>) in
                return empty
            }
        }

        let correct = [
            next(300, 1),
            next(350, 2),
            next(400, 3),
            completed(450)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450)
            ])
    }


    func testRetryWhen_ObservableNextError() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, retryError),
            completed(40)
            ])

        let res = scheduler.start(300) {
            xs.retryWhen { (errors: Observable<RetryWhenError>) in
                return errors.scan(0) { (_a, e) in
                    var a = _a
                    a += 1
                    if a == 2 {
                        throw testError1
                    }
                    return a
                }
            }
        }

        let correct = [
            next(210, 1),
            next(220, 2),
            next(240, 1),
            next(250, 2),
            error(260, testError1)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230),
            Subscription(230, 260)
            ])
    }


    func testRetryWhen_ObservableComplete() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, retryError),
            completed(40)
            ])

        let empty = scheduler.createHotObservable([
            next(150, 1),
            completed(230)
            ])

        let res = scheduler.start() {
            xs.retryWhen({ (errors: Observable<RetryWhenError>) in
                return empty.asObservable()
            })
        }

        let correct = [
            next(210, 1),
            next(220, 2),
            completed(230)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    func testRetryWhen_ObservableNextComplete() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, retryError),
            completed(40)
            ])

        let res = scheduler.start(300) {
            xs.retryWhen { (errors: Observable<RetryWhenError>) in
                return errors.scan(0) { (a, e) in
                    return a + 1
                }.takeWhile { (num: Int) -> Bool in
                    return num < 2
                }
            }
        }

        let correct = [
            next(210, 1),
            next(220, 2),
            next(240, 1),
            next(250, 2),
            completed(260)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230),
            Subscription(230, 260)
            ])
    }

    func testRetryWhen_ObservableInfinite() {

        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            error(30, retryError),
            completed(40)
            ])

        let never = scheduler.createHotObservable([
            next(150, 1)
            ])

        let res = scheduler.start() {
            xs.retryWhen { (errors: Observable<RetryWhenError>) in
                return never
            }
        }

        let correct = [
            next(210, 1),
            next(220, 2)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }


    func testRetryWhen_Incremental_BackOff() {

        let scheduler = TestScheduler(initialClock: 0)

        // just fails
        let xs = scheduler.createColdObservable([
            next(5, 1),
            error(10, retryError)
            ])

        let maxAttempts = 4

        let res = scheduler.start(800) {
            xs.retryWhen { (errors: Observable<Swift.Error>) in
                return errors.flatMapWithIndex { (e, a) -> Observable<Int64> in
                    if a >= maxAttempts - 1 {
                        return Observable.error(e)
                    }

                    return Observable<Int64>.timer(RxTimeInterval((a + 1) * 50), scheduler: scheduler)
                }
            }
        }

        let correct = [
            next(205, 1),
            next(265, 1),
            next(375, 1),
            next(535, 1),
            error(540, retryError)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210),
            Subscription(260, 270),
            Subscription(370, 380),
            Subscription(530, 540)
            ])
    }

    func testRetryWhen_IgnoresDifferentErrorTypes() {

        let scheduler = TestScheduler(initialClock: 0)

        // just fails
        let xs = scheduler.createColdObservable([
            next(5, 1),
            error(10, retryError)
            ])

        let res = scheduler.start(800) {
            xs.retryWhen { (errors: Observable<CustomErrorType>) in
                errors
            }
        }

        let correct = [
            next(205, 1),
            error(210, retryError)
        ]

        XCTAssertEqual(res.events, correct)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testRetryWhen_tailRecursiveOptimizationsTest() {
        var count = 1
        let sequenceSendingImmediateError: Observable<Int> = Observable.create { observer in
            observer.on(.next(0))
            observer.on(.next(1))
            observer.on(.next(2))
            if count < 2 {
                observer.on(.error(retryError))
                count += 1
            }
            observer.on(.next(3))
            observer.on(.next(4))
            observer.on(.next(5))
            observer.on(.completed)

            return Disposables.create()
        }

        _ = sequenceSendingImmediateError
            .retryWhen { errors in
                return errors
            }
            .subscribe { _ in
        }
    }

    #if TRACE_RESOURCES
        func testRetryWhen1ReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).retryWhen { e in e }.subscribe()
        }

        func testRetryWhen2ReleasesResourcesOnComplete() {
            _ = Observable<Int>.error(testError).retryWhen { e in e.take(1) }.subscribe()
        }

        func testRetryWhen1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).retryWhen { e in
                return e.flatMapLatest { e in
                    return Observable<Int>.error(e)
                }
            }.subscribe()
        }
    #endif
}



// MARK: IgnoreElements

extension ObservableSingleTest {
    func testIgnoreElements_DoesNotSendValues() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(210, 1),
            next(220, 2),
            completed(230)
            ])

        let res = scheduler.start {
            xs.ignoreElements()
        }

        XCTAssertEqual(res.events, [
            completed(230)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    #if TRACE_RESOURCES
        func testIgnoreElementsReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).ignoreElements().subscribe()
        }

        func testIgnoreElementsReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).ignoreElements().subscribe()
        }
    #endif
}

// scan

extension ObservableSingleTest {
    func testScan_Seed_Never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(0, 0)
            ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    func testScan_Seed_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_Return() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(250)
            ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            next(220, seed + 2),
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_Throw() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError)
            ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        XCTAssertEqual(res.events, [
            error(250, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_SomeData() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { $0 + $1 }
        }

        let messages = [
            next(210, seed + 2),
            next(220, seed + 2 + 3),
            next(230, seed + 2 + 3 + 4),
            next(240, seed + 2 + 3 + 4 + 5),
            completed(250)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testScan_Seed_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])

        let seed = 42

        let res = scheduler.start {
            xs.scan(seed) { (a, e) in
                if e == 4 {
                    throw testError
                } else {
                    return a + e
                }
            }
        }

        XCTAssertEqual(res.events, [
            next(210, seed + 2),
            next(220, seed + 2 + 3),
            error(230, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }

    #if TRACE_RESOURCES
        func testScanReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).scan(0, accumulator: +).subscribe()
        }

        func testScan1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).scan(0, accumulator: +).subscribe()
        }

        func testScan2ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).scan(0, accumulator: { _ in throw testError }).subscribe()
        }
    #endif
}

// defaultIfEmpty

extension ObservableSingleTest {
    func testDefaultIfEmpty_Source_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
                completed(201, Int.self)
            ])
        let defaultValue = 1
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [
                next(201, 1),
                completed(201)
            ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 201)
            ])
    }
    
    func testDefaultIfEmpty_Source_Errors() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
                error(201, testError, Int.self)
            ])
        let defaultValue = 1
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [
            error(201, testError)
            ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 201)
            ])
    }
    
    func testDefaultIfEmpty_Source_Emits() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
                next(201, 1),
                next(202, 2),
                next(203, 3),
                completed(204)
            ])
        let defaultValue = 42
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [
            next(201, 1),
            next(202, 2),
            next(203, 3),
            completed(204)
            ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 204)
            ])
    }
    
    func testDefaultIfEmpty_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(0, 0)
            ])
        let defaultValue = 42
        let res = scheduler.start {
            xs.ifEmpty(default: defaultValue)
        }
        
        XCTAssertEqual(res.events, [])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
    }

    #if TRACE_RESOURCES
        func testDefaultIfEmptyReleasesResourcesOnComplete1() {
            _ = Observable<Int>.just(1).ifEmpty(default: -1).subscribe()
        }

        func testDefaultIfEmptyReleasesResourcesOnComplete2() {
            _ = Observable<Int>.empty().ifEmpty(default: -1).subscribe()
        }

        func testDefaultIfEmptyReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).ifEmpty(default: -1).subscribe()
        }
    #endif
}

// materialize

extension ObservableSingleTest {
    func testMaterializeNever() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            return Observable<Int>.never().materialize()
        }
        XCTAssertEqual(res.events, [], materializedRecoredEventsComparison)
    }
    
    func testMaterializeEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            completed(201, Int.self)
            ])
        let res = scheduler.start {
            return xs.materialize()
        }
        let expectedEvents = [
            next(201, Event<Int>.completed),
            completed(201)
        ]
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 201)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    func testMaterializeEmmits() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(250)
            ])
        let res = scheduler.start {
            return xs.materialize()
        }
        let expectedEvents = [
            next(210, Event.next(2)),
            next(250, Event.completed),
            completed(250)
        ]
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    func testMaterializeThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(250, testError)
            ])
        let res = scheduler.start {
            return xs.materialize()
        }
        let expectedEvents = [
            next(250, Event<Int>.error(testError)),
            completed(250)
        ]
        
        XCTAssertEqual(xs.subscriptions, [Subscription(200, 250)])
        XCTAssertEqual(res.events, expectedEvents, materializedRecoredEventsComparison)
    }
    
    #if TRACE_RESOURCES
    func testMaterializeReleasesResourcesOnComplete1() {
        _ = Observable<Int>.just(1).materialize().subscribe()
    }
    
    func testMaterializeReleasesResourcesOnComplete2() {
        _ = Observable<Int>.empty().materialize().subscribe()
    }
    
    func testMaterializeReleasesResourcesOnError() {
        _ = Observable<Int>.error(testError).materialize().subscribe()
    }
    #endif
}

//dematerialize

extension ObservableSingleTest {
    func testDematerialize_Range1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Event.next(41)),
            next(210, Event.next(42)),
            next(220, Event.next(43)),
            completed(250)
        ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        
        XCTAssertEqual(res.events, [
                next(210, 42),
                next(220, 43),
                completed(250)
                ])
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
        
    }
    
    func testDematerialize_Range2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, Event.next(41)),
            next(210, Event.next(42)),
            next(220, Event.next(43)),
            next(230, Event.completed)
            ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            completed(230)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
        
    }
    
    func testDematerialize_Error() {
        let scheduler = TestScheduler(initialClock: 0)
    
        
        let xs = scheduler.createHotObservable([
                next(150, Event.next(41)),
                next(210, Event.next(42)),
                next(220, Event.next(43)),
                error(230, TestError.dummyError)
            ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            error(230, TestError.dummyError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
    
    func testDematerialize_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        
        let xs = scheduler.createHotObservable([
            next(150, Event.next(41)),
            next(210, Event.next(42)),
            next(220, Event.next(43)),
            next(230, Event.error(TestError.dummyError))
            ])
        
        let res = scheduler.start {
            xs.dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 42),
            next(220, 43),
            error(230, TestError.dummyError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 230)
            ])
    }
    
    func testMaterialize_Dematerialize_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = Observable<Int>.never()
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [])
    }
    
    func testMaterialize_Dematerialize_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testMaterialize_Dematerialize_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(250)
            ])
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            completed(250)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testMaterialize_Dematerialize_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        let dummyError = TestError.dummyError
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(250, dummyError)
        ])
        
        let res = scheduler.start {
            xs.materialize().dematerialize()
        }
        
        XCTAssertEqual(res.events, [
            error(250, dummyError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    #if TRACE_RESOURCES
    func testDematerializeReleasesResourcesOnComplete1() {
        _ = Observable.just(Event.next(1)).dematerialize().subscribe()
    }
    
    func testDematerializeReleasesResourcesOnComplete2() {
        _ = Observable<Event<Int>>.empty().dematerialize().subscribe()
    }
    
    func testDematerializeReleasesResourcesOnError() {
        _ = Observable<Event<Int>>.error(testError).dematerialize().subscribe()
    }
    #endif
}

fileprivate func materializedRecoredEventsComparison<T: Equatable>(lhs: [Recorded<Event<Event<T>>>], rhs: [Recorded<Event<Event<T>>>]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }
    for (lhsElement, rhsElement) in zip(lhs, rhs) {
        guard lhsElement == rhsElement else {
            return false
        }
    }
    
    return true
}

fileprivate func == <T: Equatable>(lhs: Recorded<Event<Event<T>>>, rhs: Recorded<Event<Event<T>>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

fileprivate func == <T: Equatable>(lhs: Event<Event<T>>, rhs: Event<Event<T>>) -> Bool {
    switch (lhs, rhs) {
    case (.next(let lhsEvent), .next(let rhsEvent)):
        return lhsEvent == rhsEvent
    case (.completed, .completed): return true
    case (.error(let e1), .error(let e2)):
        #if os(Linux)
            return  "\(e1)" == "\(e2)"
        #else
            let error1 = e1 as NSError
            let error2 = e2 as NSError
            
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(e1)" == "\(e2)"
        #endif
    default:
        return false
    }
}
