//
//  SingleTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 9/17/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class SingleTest : RxTest {

}

// single
extension SingleTest {
    func testSingle_Subscription_success() {
        let xs = Single.just(1)

        var events: [SingleEvent<Int>] = []

        _ = xs.subscribe { event in
            events.append(event)
        }

        XCTAssertEqual(events, [.success(1)])
    }

    func testSingle_Subscription_error() {
        let xs = Single<Int>.error(testError)

        var events: [SingleEvent<Int>] = []

        _ = xs.subscribe { event in
            events.append(event)
        }

        XCTAssertEqual(events, [.error(testError)])
    }

    func testSingle_create_success() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((SingleEvent<Int>) -> Void)! = nil

        var disposedTime: Int?

        scheduler.scheduleAt(201, action: {
            observer(.success(1))
        })
        scheduler.scheduleAt(202, action: {
            observer(.success(1))
        })
        scheduler.scheduleAt(203, action: {
            observer(.error(testError))
        })

        let res = scheduler.start {
            Single<Int>.create { _observer in
                observer = _observer
                return Disposables.create {
                    disposedTime = scheduler.clock
                }
                }.asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(201, 1),
            .completed(201)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testSingle_create_error() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((SingleEvent<Int>) -> Void)! = nil

        var disposedTime: Int?

        scheduler.scheduleAt(201, action: {
            observer(.error(testError))
        })
        scheduler.scheduleAt(202, action: {
            observer(.success(1))
        })
        scheduler.scheduleAt(203, action: {
            observer(.error(testError))
        })

        let res = scheduler.start {
            Single<Int>.create { _observer in
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

    func testSingle_create_disposing() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((SingleEvent<Int>) -> Void)! = nil
        var disposedTime: Int?
        var subscription: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(201, action: {
            subscription = Single<Int>.create { _observer in
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
            observer(.success(1))
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

extension SingleTest {
    func test_just_producesElement() {
        let result = try! (Single.just(1) as Single<Int>).toBlocking().first()!
        XCTAssertEqual(result, 1)
    }

    func test_just2_producesElement() {
        let result = try! (Single.just(1, scheduler: CurrentThreadScheduler.instance) as Single<Int>).toBlocking().first()!
        XCTAssertEqual(result, 1)
    }

    func test_error_fails() {
        do {
            _ = try (Single<Int>.error(testError) as Single<Int>).toBlocking().first()
            XCTFail()
        }
        catch let e {
            XCTAssertEqual(e as! TestError, testError)
        }
    }

    func test_never_producesElement() {
        var event: SingleEvent<Int>?
        let subscription = (Single<Int>.never() as Single<Int>).subscribe { _event in
            event = _event
        }

        XCTAssertNil(event)
        subscription.dispose()
    }

    func test_deferred() {
        let result = try! (Single.deferred { Single.just(1) } as Single<Int>).toBlocking().toArray()
        XCTAssertEqual(result, [1])
    }

    func test_delay() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.just(1).delay(.seconds(2), scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(202, 1),
            .completed(203)
            ])
    }

    func test_delaySubscription() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.just(1).delaySubscription(.seconds(2), scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(202, 1),
            .completed(202)
            ])
    }

    func test_observeOn() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.just(1).observeOn(scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(201, 1),
            .completed(202)
            ])
    }

    func test_subscribeOn() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.just(1).subscribeOn(scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(201, 1),
            .completed(201)
            ])
    }

    func test_catchError() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.error(testError).catchError { _ in Single.just(2) } as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
            ])
    }

    func test_catchErrorJustReturn() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.error(testError).catchErrorJustReturn(2) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
        ])
    }

    func test_retry() {
        let scheduler = TestScheduler(initialClock: 0)

        var isFirst = true
        let res = scheduler.start {
            (Single.error(testError)
                .catchError { e in
                    defer {
                        isFirst = false
                    }
                    if isFirst {
                        return Single.error(e)
                    }

                    return Single.just(2)
                }
                .retry(2) as Single<Int>
            ).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
            ])
    }

    func test_retryWhen1() {
        let scheduler = TestScheduler(initialClock: 0)

        var isFirst = true
        let res = scheduler.start {
            (Single.error(testError)
                .catchError { e in
                    defer {
                        isFirst = false
                    }
                    if isFirst {
                        return Single.error(e)
                    }

                    return Single.just(2)
                }
                .retryWhen { (e: Observable<Error>) in
                    return e
                } as Single<Int>
            ).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
            ])
    }

    func test_retryWhen2() {
        let scheduler = TestScheduler(initialClock: 0)

        var isFirst = true
        let res = scheduler.start {
            (Single.error(testError)
                .catchError { e in
                    defer {
                        isFirst = false
                    }
                    if isFirst {
                        return Single.error(e)
                    }

                    return Single.just(2)
                }
                .retryWhen { (e: Observable<TestError>) in
                    return e
                } as Single<Int>
            ).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
            ])
    }

    func test_debug() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.just(1).debug() as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 1),
            .completed(200)
            ])
    }

    func test_using() {
        let scheduler = TestScheduler(initialClock: 0)

        var disposeInvoked = 0
        var createInvoked = 0

        var disposable: MockDisposable!
        var xs: TestableObservable<Int>!
        var _d: MockDisposable!

        let res = scheduler.start {
            Single.using({ () -> MockDisposable in
                disposeInvoked += 1
                disposable = MockDisposable(scheduler: scheduler)
                return disposable
            }, primitiveSequenceFactory: { (d: MockDisposable) -> Single<Int> in
                _d = d
                createInvoked += 1
                xs = scheduler.createColdObservable([
                    .next(100, scheduler.clock),
                    .completed(100)
                    ])
                return xs.asObservable().asSingle()
            }).asObservable()
        }

        XCTAssert(disposable === _d)

        XCTAssertEqual(1, createInvoked)
        XCTAssertEqual(1, disposeInvoked)

        XCTAssertEqual(res.events, [
            .next(300, 200),
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
                .next(10, 1),
                .completed(20)
            ]).asSingle()

        let res = scheduler.start {
            (xs.timeout(.seconds(5), scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .error(205, RxError.timeout)
            ])
    }

    func test_timeout_other() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .next(10, 1),
            .completed(20)
            ]).asSingle()

        let xs2 = scheduler.createColdObservable([
            .next(20, 2),
            .completed(20)
            ]).asSingle()

        let res = scheduler.start {
            (xs.timeout(.seconds(5), other: xs2, scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(225, 2),
            .completed(225)
            ])
    }

    func test_timeout_succeeds() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .next(10, 1),
            .completed(20)
            ]).asSingle()

        let res = scheduler.start {
            (xs.timeout(.seconds(30), scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(220, 1),
            .completed(220)
            ])
    }

    func test_timeout_other_succeeds() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createColdObservable([
            .next(10, 1),
            .completed(20)
            ]).asSingle()

        let xs2 = scheduler.createColdObservable([
            .next(20, 2),
            .completed(20)
            ]).asSingle()

        let res = scheduler.start {
            (xs.timeout(.seconds(30), other: xs2, scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(220, 1),
            .completed(220)
            ])
    }
}

extension SingleTest {
    func test_timer() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.timer(.seconds(2), scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(202, 0),
            .completed(202)
            ])
    }
}

extension SingleTest {
    func test_do() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(1).do(onSuccess: { _ in () }, onError: { _ in () }, onSubscribe: { () in () }, onSubscribed: { () in () }, onDispose: { () in () }) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 1),
            .completed(200)
            ])
    }

    func test_filter() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(1).filter { _ in false } as Maybe<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_map() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(1).map { $0 * 2 } as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
            ])
    }

    func test_compactMap() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            (Single<String>.just("1").compactMap(Int.init) as Maybe<Int>).asObservable()
        }
        
        XCTAssertEqual(res.events, [
            .next(200, 1),
            .completed(200)
            ])
    }
    
    func test_compactMapNil() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            (Single<String>.just("a").compactMap(Int.init) as Maybe<Int>).asObservable()
        }
        
        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }
    
    func test_flatMap() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(1).flatMap { .just($0 * 2) } as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
            ])
    }

    func test_flatMapMaybe() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(1).flatMapMaybe { Maybe.just($0 * 2) } as Maybe<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 2),
            .completed(200)
            ])
    }

    func test_flatMapCompletable() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(10).flatMapCompletable { _ in Completable.empty() } as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_asMaybe() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(1).asMaybe() as Maybe<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 1),
            .completed(200)
            ])
    }

    func test_asCompletable() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.just(5).asCompletable() as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func test_asCompletableError() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single<Int>.error(testError).asCompletable() as Completable).asObservable()
        }

        XCTAssertEqual(res.events, [
            .error(200, testError)
            ])
    }
}

extension SingleTest {
    func test_zip_tuple() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.zip(Single.just(1), Single.just(2)) as Single<(Int, Int)>).map { $0.0 + $0.1 }.asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 3),
            .completed(200)
            ])
    }

    func test_zip_resultSelector() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.zip(Single.just(1), Single.just(2)) { $0 + $1 } as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            .next(200, 3),
            .completed(200)
            ])
    }
    
    func testZipCollection_selector() {
        let collection = [Single<Int>.just(1), Single<Int>.just(1), Single<Int>.just(1)]
        let singleResult: Single<Int> = Single.zip(collection) { $0.reduce(0, +) }
        
        let result = try! singleResult
            .toBlocking()
            .first()!
        
        XCTAssertEqual(result, 3)
    }
    
    func testZipCollection_selector_when_empty() {
        let collection: [Single<Int>] = []
        let singleResult = Single.zip(collection) { $0.reduce(0, +) }
        
        let result = try! singleResult
            .toBlocking()
            .first()!
        
        XCTAssertEqual(result, 0)
    }
    
    func testZipCollection_tuple() {
        let collection = [Single<Int>.just(1), Single<Int>.just(1), Single<Int>.just(1)]
        let singleResult: Single<Int> = Single.zip(collection).map { $0.reduce(0, +) }
        
        let result = try! singleResult
            .toBlocking()
            .first()!
        
        XCTAssertEqual(result, 3)
    }
    
    func testZipCollection_tuple_when_empty() {
        let collection: [Single<Int>] = []
        let singleResult = Single.zip(collection)
        
        let result = try! singleResult
            .toBlocking()
            .first()!
        
        XCTAssertEqual(result, [])
    }
}

extension SingleTest {
    func testDefaultErrorHandler() {
        var loggedErrors = [TestError]()

        _ = Single<Int>.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [])

        let originalErrorHandler = Hooks.defaultErrorHandler

        Hooks.defaultErrorHandler = { _, error in
            loggedErrors.append(error as! TestError)
        }

        _ = Single<Int>.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [testError])

        Hooks.defaultErrorHandler = originalErrorHandler

        _ = Single<Int>.error(testError).subscribe()
        XCTAssertEqual(loggedErrors, [testError])
    }
}
