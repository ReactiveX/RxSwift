//
//  Observable+PrimitiveSequenceTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 9/17/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservablePrimitiveSequenceTest : RxTest {

}

extension ObservablePrimitiveSequenceTest {
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

    func testAsSingle_subscribeOnSuccess() {
        var events: [SingleEvent<Int>] = []

        _ = Single.just(1).subscribe(onSuccess: { element in
            events.append(.success(element))
        }, onError: { error in
            events.append(.error(error))
        })

        XCTAssertEqual(events, [.success(1)])
    }

    func testAsSingle_subscribeOnError() {
        var events: [SingleEvent<Int>] = []

        _ = Single.error(testError).subscribe(onSuccess: { element in
            events.append(.success(element))
        }, onError: { error in
            events.append(.error(error))
        })

        XCTAssertEqual(events, [.error(testError)])
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

extension ObservablePrimitiveSequenceTest {
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

    func testAsMaybe_subscribeOnSuccess() {
        var events: [MaybeEvent<Int>] = []

        _ = Maybe.just(1).subscribe(onSuccess: { element in
            events.append(.success(element))
        }, onError: { error in
            events.append(.error(error))
        }, onCompleted: {
            events.append(.completed)
        })

        XCTAssertEqual(events, [.success(1)])
    }

    func testAsMaybe_subscribeOnError() {
        var events: [MaybeEvent<Int>] = []

        _ = Maybe.error(testError).subscribe(onSuccess: { element in
            events.append(.success(element))
        }, onError: { error in
            events.append(.error(error))
        }, onCompleted: {
            events.append(.completed)
        })

        XCTAssertEqual(events, [.error(testError)])
    }

    func testAsMaybe_subscribeOnCompleted() {
        var events: [MaybeEvent<Int>] = []

        _ = Maybe.empty().subscribe(onSuccess: { element in
            events.append(.success(element))
        }, onError: { error in
            events.append(.error(error))
        }, onCompleted: {
            events.append(.completed)
        })

        XCTAssertEqual(events, [.completed])
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

extension ObservablePrimitiveSequenceTest {
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

    func testAsCompletable_subscribeOnCompleted() {
        var events: [CompletableEvent] = []

        _ = Completable.empty().subscribe(onCompleted: {
            events.append(.completed)
        }, onError: { error in
            events.append(.error(error))
        })

        XCTAssertEqual(events, [.completed])
    }

    func testAsCompletable_subscribeOnError() {
        var events: [CompletableEvent] = []

        _ = Completable.error(testError).subscribe(onCompleted: {
            events.append(.completed)
        }, onError: { error in
            events.append(.error(error))
        })

        XCTAssertEqual(events, [.error(testError)])
    }

    #if TRACE_RESOURCES
    func testAsCompletableReleasesResourcesOnComplete() {
        _ = Observable<Never>.empty().asCompletable().subscribe({ _ in })
    }

    func testAsCompletableReleasesResourcesOnError() {
        _ = Observable<Never>.error(testError).asCompletable().subscribe({ _ in })
    }
    #endif

    func testCompletable_merge() {
        let factories: [(Completable, Completable) -> Completable] =
            [
                { ys1, ys2 in Completable.merge(ys1, ys2) },
                { ys1, ys2 in Completable.merge([ys1, ys2]) },
                { ys1, ys2 in Completable.merge(AnyCollection([ys1, ys2])) },
                ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let ys1 = scheduler.createHotObservable([
                completed(250, Never.self),
                error(260, testError)
                ])

            let ys2 = scheduler.createHotObservable([
                completed(300, Never.self)
                ])

            let res = scheduler.start { () -> Observable<Never> in
                let completable: Completable = factory(ys1.asCompletable(), ys2.asCompletable())
                return completable.asObservable()
            }

            XCTAssertEqual(res.events, [
                completed(300)
                ])

            XCTAssertEqual(ys1.subscriptions, [
                Subscription(200, 250),
                ])

            XCTAssertEqual(ys2.subscriptions, [
                Subscription(200, 300),
                ])
        }
    }

    func testCompletable_concat() {
        let factories: [(Completable, Completable) -> Completable] =
            [
                { ys1, ys2 in Completable.concat(ys1, ys2) },
                { ys1, ys2 in Completable.concat([ys1, ys2]) },
                { ys1, ys2 in Completable.concat(AnyCollection([ys1, ys2])) },
                { ys1, ys2 in ys1.concat(ys2) }
        ]

        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let ys1 = scheduler.createHotObservable([
                completed(250, Never.self),
                error(260, testError)
                ])

            let ys2 = scheduler.createHotObservable([
                completed(300, Never.self)
                ])

            let res = scheduler.start { () -> Observable<Never> in
                let completable: Completable = factory(ys1.asCompletable(), ys2.asCompletable())
                return completable.asObservable()
            }

            XCTAssertEqual(res.events, [
                completed(300)
                ])

            XCTAssertEqual(ys1.subscriptions, [
                Subscription(200, 250),
                ])

            XCTAssertEqual(ys2.subscriptions, [
                Subscription(250, 300),
                ])
        }
    }
}
