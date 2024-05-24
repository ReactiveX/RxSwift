//
//  Completable+AndThen.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/2/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class CompletableAndThenTest : RxTest {
}

extension CompletableAndThenTest {

    func testCompletableEmpty_CompletableCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: Completable = Completable.empty()

        let x2: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(290),
            ])

        let res = scheduler.start {
            x1.andThen(x2.asCompletable())
        }

        XCTAssertEqual(res.events, [
            .completed(290)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 290)
            ])
    }

    func testCompletableCompleted_CompletableCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asCompletable())
        }

        XCTAssertEqual(res.events, [
            .completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    func testCompletableError_CompletableCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .error(210, testError),
            ])

        let x2: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asCompletable())
        }

        XCTAssertEqual(res.events, [
            .error(210, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_CompletableError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Never> = scheduler.createHotObservable([
            .error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asCompletable())
        }

        XCTAssertEqual(res.events, [
            .error(290, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    func testCompletable_FirstCompletableNotRetainedBeyondCompletion() {
        let scheduler = TestScheduler(initialClock: 0)

        let x: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
        ])

        var object = Optional.some(TestObject())

        var completable = x.asCompletable()
            .do(onCompleted: { [object] in
                _ = object
            })

        let disposable = completable
            .andThen(.never())
            .subscribe()

        defer {
            disposable.dispose()
        }

        // completable has completed by now
        scheduler.advanceTo(300)

        weak var weakObject = object
        object = nil
        completable = .never()

        XCTAssertNil(weakObject)
    }

    func testCompletable_FirstCompletableNotRetainedBeyondFailure() {
        let scheduler = TestScheduler(initialClock: 0)

        let x: TestableObservable<Never> = scheduler.createHotObservable([
            .error(210, TestError.dummyError),
        ])

        var object = Optional.some(TestObject())

        var completable = x.asCompletable()
            .do(onCompleted: { [object] in
                _ = object
            })

        let disposable = completable
            .andThen(.never())
            .subscribe()

        defer {
            disposable.dispose()
        }

        // completable has terminated with error by now
        scheduler.advanceTo(300)

        weak var weakObject = object
        object = nil
        completable = .never()

        XCTAssertNil(weakObject)
    }

    #if TRACE_RESOURCES
        func testAndThenCompletableReleasesResourcesOnComplete() {
            _ = Completable.empty().andThen(Completable.empty()).subscribe()
        }

        func testAndThenCompletableReleasesResourcesOnError1() {
            _ = Completable.error(testError).andThen(Completable.empty()).subscribe()
        }

        func testAndThenCompletableReleasesResourcesOnError2() {
            _ = Completable.empty().andThen(Completable.error(testError)).subscribe()
        }
    #endif
}

extension CompletableAndThenTest {

    func testCompletableEmpty_SingleCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: Completable = Completable.empty()

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(285, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.andThen(x2.asSingle())
        }

        XCTAssertEqual(res.events, [
            .next(290, 1),
            .completed(290)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 290)
            ])
    }
    
    func testCompletableCompleted_SingleNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(290, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asSingle())
        }

        XCTAssertEqual(res.events, [
            .next(290, 1),
            .completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }


    func testCompletableError_SingleNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .error(210, testError),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(290, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asSingle())
        }

        XCTAssertEqual(res.events, [
            .error(210, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_SingleError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asSingle())
        }

        XCTAssertEqual(res.events, [
            .error(290, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    #if TRACE_RESOURCES
        func testAndThenSingleReleasesResourcesOnComplete() {
            _ = Completable.empty().andThen(Single.just(1)).subscribe()
        }
    
        func testAndThenSingleReleasesResourcesOnError1() {
            _ = Completable.error(testError).andThen(Single.just(1)).subscribe()
        }
    
        func testAndThenSingleReleasesResourcesOnError2() {
            _ = Completable.empty().andThen(Single<Int>.error(testError)).subscribe()
        }
    #endif
}

extension CompletableAndThenTest {

    func testCompletableEmpty_MaybeCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: Completable = Completable.empty()

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(285, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.andThen(x2.asMaybe())
        }

        XCTAssertEqual(res.events, [
            .next(290, 1),
            .completed(290)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 290)
            ])
    }
    
    func testCompletableCompleted_MaybeNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(290, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe())
        }

        XCTAssertEqual(res.events, [
            .next(290, 1),
            .completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }


    func testCompletableError_MaybeNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .error(210, testError),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(290, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe())
        }

        XCTAssertEqual(res.events, [
            .error(210, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_MaybeError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe())
        }

        XCTAssertEqual(res.events, [
            .error(290, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    func testCompletableCompleted_MaybeEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .completed(290)
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asMaybe())
        }

        XCTAssertEqual(res.events, [
            .completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    #if TRACE_RESOURCES
        func testAndThenMaybeReleasesResourcesOnComplete() {
            _ = Completable.empty().andThen(Maybe.just(1)).subscribe()
        }
    
        func testAndThenMaybeReleasesResourcesOnError1() {
            _ = Completable.error(testError).andThen(Maybe.just(1)).subscribe()
        }
    
        func testAndThenMaybeReleasesResourcesOnError2() {
            _ = Completable.empty().andThen(Maybe<Int>.error(testError)).subscribe()
        }
    #endif
}

extension CompletableAndThenTest {

    func testCompletableEmpty_ObservableCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: Completable = Completable.empty()

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(285, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            .next(285, 1),
            .completed(290)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(200, 290)
            ])
    }

    func testCompletableCompleted_ObservableNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(280, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            .next(280, 1),
            .completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }


    func testCompletableError_ObservableNormal() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .error(210, testError),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .next(280, 1),
            .completed(290),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            .error(210, testError),
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            ])
    }

    func testCompletableCompleted_ObservableError() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .error(290, testError),
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            .error(290, testError)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])

        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }

    func testCompletableCompleted_ObservableEmpty() {
        let scheduler = TestScheduler(initialClock: 0)

        let x1: TestableObservable<Never> = scheduler.createHotObservable([
            .completed(210),
            ])

        let x2: TestableObservable<Int> = scheduler.createHotObservable([
            .completed(290)
            ])

        let res = scheduler.start {
            x1.asCompletable().andThen(x2.asObservable())
        }

        XCTAssertEqual(res.events, [
            .completed(290)
            ])

        XCTAssertEqual(x1.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(x2.subscriptions, [
            Subscription(210, 290)
            ])
    }


    #if TRACE_RESOURCES
        func testAndThenObservableReleasesResourcesOnComplete() {
            _ = Completable.empty().andThen(Observable.just(1)).subscribe()
        }

        func testAndThenObservableReleasesResourcesOnError1() {
            _ = Completable.error(testError).andThen(Observable.just(1)).subscribe()
        }

        func testAndThenObservableReleasesResourcesOnError2() {
            _ = Completable.empty().andThen(Observable<Int>.error(testError)).subscribe()
        }
    #endif
}

private class TestObject {
}
