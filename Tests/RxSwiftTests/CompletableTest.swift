//
//  CompletableTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 9/17/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class CompletableTest : RxTest {

}

// completable
extension CompletableTest {
    func testCompletable_Subscription_completed() {
        let xs = Completable.empty()

        var events: [CompletableEvent] = []

        _ = xs.subscribe { event in
            events.append(event)
        }

        XCTAssertEqual(events, [.completed])
    }

    func testCompletable_Subscription_error() {
        let xs = Completable.error(testError)

        var events: [CompletableEvent] = []

        _ = xs.subscribe { event in
            events.append(event)
        }

        XCTAssertEqual(events, [.error(testError)])
    }

    func testCompletable_create_completed() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((CompletableEvent) -> Void)! = nil

        var disposedTime: Int?

        scheduler.scheduleAt(201, action: {
            observer(.completed)
        })
        scheduler.scheduleAt(203, action: {
            observer(.error(testError))
        })
        scheduler.scheduleAt(204, action: {
            observer(.completed)
        })

        let res = scheduler.start {
            Completable.create { _observer in
                observer = _observer
                return Disposables.create {
                    disposedTime = scheduler.clock
                }
                }.asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(201, Never.self)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testCompletable_create_error() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((CompletableEvent) -> Void)! = nil

        var disposedTime: Int?

        scheduler.scheduleAt(201, action: {
            observer(.error(testError))
        })
        scheduler.scheduleAt(202, action: {
            observer(.completed)
        })
        scheduler.scheduleAt(203, action: {
            observer(.error(testError))
        })

        let res = scheduler.start {
            Completable.create { _observer in
                observer = _observer
                return Disposables.create {
                    disposedTime = scheduler.clock
                }
                }.asObservable()
        }

        XCTAssertEqual(res.events, [
            .error(201, testError)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testCompletable_create_disposing() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((CompletableEvent) -> Void)! = nil
        var disposedTime: Int?
        var subscription: Disposable! = nil
        let res = scheduler.createObserver(Never.self)

        scheduler.scheduleAt(201, action: {
            subscription = Completable.create { _observer in
                observer = _observer
                return Disposables.create {
                    disposedTime = scheduler.clock
                }
                }
                .asObservable()
                .subscribe(res)
        })
        scheduler.scheduleAt(202, action: {
            subscription.dispose()
        })
        scheduler.scheduleAt(203, action: {
            observer(.completed)
        })
        scheduler.scheduleAt(204, action: {
            observer(.error(testError))
        })

        scheduler.start()

        XCTAssertEqual(res.events, [
            ])

        XCTAssertEqual(disposedTime, 202)
    }
}

extension CompletableTest {
    func test_error_fails() {
        do {
            _ = try Completable.error(testError).toBlocking().first()
            XCTFail()
        }
        catch let e {
            XCTAssertEqual(e as! TestError, testError)
        }
    }

    func test_never_producesElement() {
        var event: CompletableEvent?
        let subscription = Completable.never().subscribe { _event in
            event = _event
        }

        XCTAssertNil(event)
        subscription.dispose()
    }

    func test_deferred() {
        let result = try! (Completable.deferred { Completable.empty() } as Completable).toBlocking().toArray()
        XCTAssertEqual(result, [])
    }

    func test_delaySubscription() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.empty().delaySubscription(2.0, scheduler: scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(202)
            ])
    }

    func test_delay() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.empty().delay(2.0, scheduler: scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(202)
            ])
    }

    func test_observeOn() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.empty().observeOn(scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(201)
            ])
    }

    func test_subscribeOn() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.empty().subscribeOn(scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(201)
            ])
    }

    func test_catchError() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.error(testError).catchError { _ in Completable.empty() } as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_retry() {
        let scheduler = TestScheduler(initialClock: 0)

        var isFirst = true
        let res = scheduler.start {
            (Completable.error(testError)
                .catchError { e in
                    defer {
                        isFirst = false
                    }
                    if isFirst {
                        return Completable.error(e)
                    }

                    return Completable.empty()
                }
                .retry(2) as Completable
            ).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_retryWhen1() {
        let scheduler = TestScheduler(initialClock: 0)

        var isFirst = true
        let res = scheduler.start {
            (Completable.error(testError)
                .catchError { e in
                    defer {
                        isFirst = false
                    }
                    if isFirst {
                        return Completable.error(e)
                    }

                    return Completable.empty()
                }
                .retryWhen { (e: Observable<Error>) in
                    return e
                } as Completable
            ).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_retryWhen2() {
        let scheduler = TestScheduler(initialClock: 0)

        var isFirst = true
        let res = scheduler.start {
            (Completable.error(testError)
                .catchError { e in
                    defer {
                        isFirst = false
                    }
                    if isFirst {
                        return Completable.error(e)
                    }

                    return Completable.empty()
                }
                .retryWhen { (e: Observable<TestError>) in
                    return e
                } as Completable
            ).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_debug() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.empty().debug() as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_using() {
        let scheduler = TestScheduler(initialClock: 0)

        var disposeInvoked = 0
        var createInvoked = 0

        var disposable: MockDisposable!
        var xs: TestableObservable<Never>!
        var _d: MockDisposable!

        let res = scheduler.start {
            Completable.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
            }, primitiveSequenceFactory: { (d: MockDisposable) -> Completable in
                _d = d
                createInvoked += 1
                xs = scheduler.createColdObservable([
                    .completed(100)
                    ])
                return xs.asObservable().asCompletable()
            }).asObservable()
        }

        XCTAssert(disposable === _d)

        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)

        XCTAssertEqual(res.events, [
            .completed(300)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])

        XCTAssertEqual(disposable.ticks, [
            200,
            300
            ])
    }

    func test_timeout() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .completed(20)
            ]).asCompletable()

        let res = scheduler.start {
            (xs.timeout(5.0, scheduler: scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .error(205, RxError.timeout)
            ])
    }

    func test_timeout_other() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .completed(20)
            ]).asCompletable()

        let xs2 = scheduler.createColdObservable([
            .completed(20)
            ]).asCompletable()

        let res = scheduler.start {
            (xs.timeout(5.0, other: xs2, scheduler: scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(225)
            ])
    }

    func test_timeout_succeeds() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .completed(20)
            ]).asCompletable()

        let res = scheduler.start {
            (xs.timeout(30.0, scheduler: scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(220)
            ])
    }

    func test_timeout_other_succeeds() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .completed(20)
            ]).asCompletable()

        let xs2 = scheduler.createColdObservable([
            .completed(20)
            ]).asCompletable()

        let res = scheduler.start {
            (xs.timeout(30.0, other: xs2, scheduler: scheduler) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(220)
            ])
    }
}

extension CompletableTest {
    func test_do() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.empty().do(onError: { _ in () }, onSubscribe: { () in () }, onSubscribed: { () in () }, onDispose: { () in () }) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_concat() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.empty().concat(Completable.empty()) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_concat_sequence() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.concat(AnySequence([Completable.empty()])) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_concat_collection() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.concat([Completable.empty()]) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_concat_variadic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.concat(Completable.empty(), Completable.empty()) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_merge_collection() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.merge(AnyCollection([Completable.empty(), Completable.empty()])) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_merge_array() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.merge([Completable.empty(), Completable.empty()]) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_merge_variadic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Completable.merge(Completable.empty(), Completable.empty()) as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }
}

extension CompletableTest {
    func testDefaultErrorHandler() {
        var loggedErrors = [TestError]()

        _ = Completable.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [])

        let originalErrorHandler = Hooks.defaultErrorHandler

        Hooks.defaultErrorHandler = { _, error in
            loggedErrors.append(error as! TestError)
        }

        _ = Completable.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [testError])

        Hooks.defaultErrorHandler = originalErrorHandler

        _ = Completable.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [testError])
    }
}

extension Never: Equatable {

}

public func == (lhs: Never, rhs: Never) -> Bool {
    fatalError()
}
