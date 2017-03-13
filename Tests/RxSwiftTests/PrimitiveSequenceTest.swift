//
//  PrimitiveSequenceTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/11/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class PrimitiveSequenceTest : RxTest {

}

// single
extension PrimitiveSequenceTest {
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

        var observer: ((SingleEvent<Int>) -> ())! = nil

        var disposedTime: Int? = nil

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
            next(201, 1),
            completed(201)
        ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testSingle_create_error() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((SingleEvent<Int>) -> ())! = nil

        var disposedTime: Int? = nil

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
            error(201, testError)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testSingle_create_disposing() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((SingleEvent<Int>) -> ())! = nil
        var disposedTime: Int? = nil
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

// maybe
extension PrimitiveSequenceTest {
    func testMaybe_Subscription_success() {
        let xs = Maybe.just(1)

        var events: [MaybeEvent<Int>] = []

        _ = xs.subscribe { event in
            events.append(event)
        }

        XCTAssertEqual(events, [.success(1)])
    }

    func testMaybe_Subscription_completed() {
        let xs = Maybe<Int>.empty()

        var events: [MaybeEvent<Int>] = []

        _ = xs.subscribe { event in
            events.append(event)
        }

        XCTAssertEqual(events, [.completed])
    }

    func testMaybe_Subscription_error() {
        let xs = Maybe<Int>.error(testError)

        var events: [MaybeEvent<Int>] = []

        _ = xs.subscribe { event in
            events.append(event)
        }

        XCTAssertEqual(events, [.error(testError)])
    }

    func testMaybe_create_success() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((MaybeEvent<Int>) -> ())! = nil

        var disposedTime: Int? = nil

        scheduler.scheduleAt(201, action: {
            observer(.success(1))
        })
        scheduler.scheduleAt(202, action: {
            observer(.success(1))
        })
        scheduler.scheduleAt(203, action: {
            observer(.error(testError))
        })
        scheduler.scheduleAt(204, action: {
            observer(.completed)
        })

        let res = scheduler.start {
            Maybe<Int>.create { _observer in
                observer = _observer
                return Disposables.create {
                    disposedTime = scheduler.clock
                }
            }.asObservable()
        }

        XCTAssertEqual(res.events, [
            next(201, 1),
            completed(201)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testMaybe_create_completed() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((MaybeEvent<Int>) -> ())! = nil

        var disposedTime: Int? = nil

        scheduler.scheduleAt(201, action: {
            observer(.completed)
        })
        scheduler.scheduleAt(202, action: {
            observer(.success(1))
        })
        scheduler.scheduleAt(203, action: {
            observer(.error(testError))
        })
        scheduler.scheduleAt(204, action: {
            observer(.completed)
        })

        let res = scheduler.start {
            Maybe<Int>.create { _observer in
                observer = _observer
                return Disposables.create {
                    disposedTime = scheduler.clock
                }
            }.asObservable()
        }

        XCTAssertEqual(res.events, [
            completed(201)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testMaybe_create_error() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((MaybeEvent<Int>) -> ())! = nil

        var disposedTime: Int? = nil

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
            Maybe<Int>.create { _observer in
                observer = _observer
                return Disposables.create {
                    disposedTime = scheduler.clock
                }
            }.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(201, testError)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testMaybe_create_disposing() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((MaybeEvent<Int>) -> ())! = nil
        var disposedTime: Int? = nil
        var subscription: Disposable! = nil
        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(201, action: {
            subscription = Maybe<Int>.create { _observer in
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

// completable
extension PrimitiveSequenceTest {
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

        var observer: ((CompletableEvent) -> ())! = nil

        var disposedTime: Int? = nil

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
            completed(201, Never.self)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testCompletable_create_error() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((CompletableEvent) -> ())! = nil

        var disposedTime: Int? = nil

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
            error(201, testError)
            ])

        XCTAssertEqual(disposedTime, 201)
    }

    func testCompletable_create_disposing() {
        let scheduler = TestScheduler(initialClock: 0)

        var observer: ((CompletableEvent) -> ())! = nil
        var disposedTime: Int? = nil
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

// single operators
extension PrimitiveSequenceTest {
    func testSingle_deferred_producesSingleElement() {
        let result = try! (Single.deferred { Single.just(1) } as Single<Int>).toBlocking().first()!
        XCTAssertEqual(result, 1)
    }

    func testSingle_just_producesSingleElement() {
        let result = try! (Single.just(1) as Single<Int>).toBlocking().first()!
        XCTAssertEqual(result, 1)
    }

    func testSingle_just2_producesSingleElement() {
        let result = try! (Single.just(1, scheduler: CurrentThreadScheduler.instance) as Single<Int>).toBlocking().first()!
        XCTAssertEqual(result, 1)
    }

    func testSingle_error_fails() {
        do {
            _ = try (Single<Int>.error(testError) as Single<Int>).toBlocking().first()
            XCTFail()
        }
        catch let e {
            XCTAssertEqual(e as! TestError, testError)
        }
    }

    func testSingle_never_producesSingleElement() {
        var event: SingleEvent<Int>? = nil
        let subscription = (Single<Int>.never() as Single<Int>).subscribe { _event in
            event = _event
        }

        XCTAssertNil(event)
        subscription.dispose()
    }

    func testSingle_delaySubscription_producesSingleElement() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.just(1).delaySubscription(1.0, scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            next(201, 1),
            completed(201)
            ])
    }

    func testSingle_delay_producesSingleElement() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            (Single.just(1)
                .delay(1.0, scheduler: scheduler) as Single<Int>).asObservable()
        }

        XCTAssertEqual(res.events, [
            next(201, 1),
            completed(202)
            ])
    }

    func testSingle_do_producesSingleElement() {
        let singleResult: Single<Int> = Single.just(1)
            .do()

        let result = try! singleResult
            .toBlocking().first()!
        XCTAssertEqual(result, 1)
    }

    func testSingle_filter_resultIsMaybe() {
        let filterResult: Maybe<Int> = Single.just(1)
            .filter { _ in false }

        XCTAssertNil(try! filterResult.toBlocking().first())
    }

    func testSingle_map_producesSingleElement() {
        let singleResult: Single<Int> = Single.just(1)
            .map { $0 * 2 }

        let result = try! singleResult
            .toBlocking().first()!
        XCTAssertEqual(result, 2)
    }

    func testSingle_flatMap_producesSingleElement() {
        let singleResult: Single<Int> = Single.just(1)
            .flatMap { Single.just($0 * 2) }

        let result = try! singleResult
            .toBlocking().first()!
        XCTAssertEqual(result, 2)
    }

    func testSingle_observeOn_producesSingleElement() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start { () -> Observable<Int> in
            let singleResult: Single<Int> = Single.just(1)
                .observeOn(scheduler)

            return singleResult.asObservable()
        }

        XCTAssertEqual(res.events, [
            next(201, 1),
            completed(202)
            ])
    }

    func testSingle_subscribeOn_producesSingleElement() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start { () -> Observable<Int> in
            let singleResult: Single<Int> = Single.just(1)
                .subscribeOn(scheduler)

            return singleResult.asObservable()
        }

        XCTAssertEqual(res.events, [
            next(201, 1),
            completed(201)
            ])
    }

    func testSingle_catchError_producesSingleElement() {
        let singleResult: Single<Int> = Single.error(testError)
            .catchError { _ in Single.just(2) }

        let result = try! singleResult
            .toBlocking().first()!
        XCTAssertEqual(result, 2)
    }

    func testSingle_retry_producesSingleElement() {
        var isFirst = true
        let singleResult: Single<Int> = Single.error(testError)
            .catchError { e in
                defer {
                    isFirst = false
                }
                if isFirst {
                    return Single.error(e)
                }

                return Single.just(2)
            }
            .retry(2)

        let result = try! singleResult
            .toBlocking().first()!
        XCTAssertEqual(result, 2)
    }

    func testSingle_retryWhen1_producesSingleElement() {
        var isFirst = true
        let singleResult: Single<Int> = Single.error(testError)
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
            }

        let result = try! singleResult
            .toBlocking().first()!
        XCTAssertEqual(result, 2)
    }

    func testSingle_retryWhen2_producesSingleElement() {
        var isFirst = true
        let singleResult: Single<Int> = Single.error(testError)
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
        }

        let result = try! singleResult
            .toBlocking().first()!
        XCTAssertEqual(result, 2)
    }

    func testSingle_timer_producesSingleElement() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start { () -> Observable<Int> in
            let singleResult: Single<Int> = Single<Int>.timer(2, scheduler: scheduler)

            return singleResult.asObservable()
        }

        XCTAssertEqual(res.events, [
            next(202, 0),
            completed(202)
            ])
    }
}

extension PrimitiveSequenceTest {
    func testAsSingle_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250),
            error(260, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let single: Single<Int> = xs.asSingle()
            return single.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(250, RxError.noElements)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testAsSingle_One() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(250),
            error(260, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let single: Single<Int> = xs.asSingle()
            return single.asObservable()
        }

        XCTAssertEqual(res.events, [
            next(250, 2),
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testAsSingle_Many() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250),
            error(260, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let single: Single<Int> = xs.asSingle()
            return single.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(220, RxError.moreThanOneElement)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220)
            ])
    }

    func testAsSingle_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let single: Single<Int> = xs.asSingle()
            return single.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testAsSingle_Error2() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(205, 2),
            error(210, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let single: Single<Int> = xs.asSingle()
            return single.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    #if TRACE_RESOURCES
        func testAsSingleReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).asSingle().subscribe({ _ in })
        }

        func testAsSingleReleasesResourcesOnError1() {
        _ = Observable<Int>.error(testError).asSingle().subscribe({ _ in })
        }

        func testAsSingleReleasesResourcesOnError2() {
        _ = Observable<Int>.of(1, 2).asSingle().subscribe({ _ in })
        }
    #endif
}

extension PrimitiveSequenceTest {
    func testAsMaybe_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250),
            error(260, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let maybe: Maybe<Int> = xs.asMaybe()
            return maybe.asObservable()
        }

        XCTAssertEqual(res.events, [
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testAsMaybe_One() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(250),
            error(260, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let maybe: Maybe<Int> = xs.asMaybe()
            return maybe.asObservable()
        }

        XCTAssertEqual(res.events, [
            next(250, 2),
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testAsMaybe_Many() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250),
            error(260, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let maybe: Maybe<Int> = xs.asMaybe()
            return maybe.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(220, RxError.moreThanOneElement)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 220)
            ])
    }

    func testAsMaybe_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let maybe: Maybe<Int> = xs.asMaybe()
            return maybe.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    func testAsMaybe_Error2() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(205, 2),
            error(210, testError)
            ])

        let res = scheduler.start { () -> Observable<Int> in
            let maybe: Maybe<Int> = xs.asMaybe()
            return maybe.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    #if TRACE_RESOURCES
        func testAsMaybeReleasesResourcesOnComplete1() {
            _ = Observable<Int>.empty().asMaybe().subscribe({ _ in })
        }

        func testAsMaybeReleasesResourcesOnComplete2() {
            _ = Observable<Int>.just(1).asMaybe().subscribe({ _ in })
        }

        func testAsMaybeReleasesResourcesOnError1() {
            _ = Observable<Int>.error(testError).asMaybe().subscribe({ _ in })
        }

        func testAsMaybeReleasesResourcesOnError2() {
            _ = Observable<Int>.of(1, 2).asMaybe().subscribe({ _ in })
        }
    #endif
}

extension PrimitiveSequenceTest {
    func testAsCompletable_Empty() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            completed(250, Never.self),
            error(260, testError)
            ])

        let res = scheduler.start { () -> Observable<Never> in
            let completable: Completable = xs.asCompletable()
            return completable.asObservable()
        }

        XCTAssertEqual(res.events, [
            completed(250)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testAsCompletable_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            error(210, testError, Never.self)
            ])

        let res = scheduler.start { () -> Observable<Never> in
            let completable: Completable = xs.asCompletable()
            return completable.asObservable()
        }

        XCTAssertEqual(res.events, [
            error(210, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 210)
            ])
    }

    #if TRACE_RESOURCES
        func testAsCompletableReleasesResourcesOnComplete() {
            _ = Observable<Never>.empty().asCompletable().subscribe({ _ in })
        }

        func testAsCompletableReleasesResourcesOnError() {
            _ = Observable<Never>.error(testError).asCompletable().subscribe({ _ in })
        }
    #endif
}

extension Never: Equatable {

}

public func == (lhs: Never, rhs: Never) -> Bool {
    fatalError()
}
