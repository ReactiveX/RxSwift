//
//  Infallible+Tests.swift
//  Tests
//
//  Created by Shai Mishali on 11/20/20.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import RxTest
import XCTest

class InfallibleTest: RxTest {

}

extension InfallibleTest {
    func testAsInfallible_OnErrorJustReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .error(390, testError),
            .next(480, 320),
        ])

        let inf = xs.asInfallible(onErrorJustReturn: 600)
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .next(390, 600),
            .completed(390)
        ])
    }

    func testAsInfallible_OnErrorFallbackTo() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .error(390, testError),
            .next(480, 320),
        ])

        let inf = xs.asInfallible(onErrorFallbackTo: Infallible<Int>.of(1, 2))
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .next(390, 1),
            .next(390, 2),
            .completed(390)
        ])
    }

    func testAsInfallible_OnErrorRecover() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .error(390, testError),
            .next(480, 320),
        ])

        let ys = scheduler.createHotObservable([
            .next(500, 25),
            .next(600, 33),
            .completed(620)
        ])

        let inf = xs.asInfallible(onErrorRecover: { _ in ys.asInfallible(onErrorJustReturn: -1) })
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .next(500, 25),
            .next(600, 33),
            .completed(620)
        ])
    }

    func testAnonymousInfallible_detachesOnDispose() {
        var observer: ((InfallibleEvent<Int>) -> Void)!
        let a = Infallible.create { o in
            observer = o
            return Disposables.create()
        } as Infallible<Int>

        var elements = [Int]()

        let d = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])

        observer(.next(0))
        XCTAssertEqual(elements, [0])

        d.dispose()

        observer(.next(1))
        XCTAssertEqual(elements, [0])
    }

    func testAnonymousInfallible_detachesOnComplete() {
        var observer: ((InfallibleEvent<Int>) -> Void)!
        let a = Infallible.create { o in
            observer = o
            return Disposables.create()
        } as Infallible<Int>

        var elements = [Int]()

        _ = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])

        observer(.next(0))
        XCTAssertEqual(elements, [0])

        observer(.completed)

        observer(.next(1))
        XCTAssertEqual(elements, [0])
    }
}

extension InfallibleTest {
    func testAsInfallible_never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: Infallible<Int> = Infallible.never()

        let res = scheduler.start { xs }

        let correct: [Recorded<Event<Int>>] = []

        XCTAssertEqual(res.events, correct)
    }

    #if TRACE_RESOURCES
        func testAsInfallibleReleasesResourcesOnComplete() {
            _ = Observable<Int>.empty().asInfallible(onErrorJustReturn: 0).subscribe()
        }

        func testAsInfallibleReleasesResourcesOnError() {
            _ = Observable<Int>.empty().asInfallible(onErrorJustReturn: 0).subscribe()
        }
    #endif
}
