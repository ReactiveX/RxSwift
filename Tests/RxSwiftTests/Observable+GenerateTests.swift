//
//  Observable+GenerateTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableGenerateTest : RxTest {
}

extension ObservableGenerateTest {
    func testGenerate_Finite() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable.generate(initialState: 0, condition: { x in x <= 3 }, scheduler: scheduler) { x in
                x + 1
            }
        }

        XCTAssertEqual(res.events, [
            .next(201, 0),
            .next(202, 1),
            .next(203, 2),
            .next(204, 3),
            .completed(205)
            ])

    }

    func testGenerate_ThrowCondition() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable.generate(initialState: 0, condition: { _ in throw testError }, scheduler: scheduler) { x in
                x + 1
            }
        }

        XCTAssertEqual(res.events, [
            .error(201, testError)
            ])

    }

    func testGenerate_ThrowIterate() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable.generate(initialState: 0, condition: { _ in true }, scheduler: scheduler) { (_: Int) -> Int in
                throw testError
            }
        }

        XCTAssertEqual(res.events, [
            .next(201, 0),
            .error(202, testError)
            ])

    }

    func testGenerate_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(disposed: 203) {
            Observable.generate(initialState: 0, condition: { _ in true }, scheduler: scheduler) { x in
                x + 1
            }
        }

        XCTAssertEqual(res.events, [
            .next(201, 0),
            .next(202, 1)
            ])

    }

    func testGenerate_take() {
        var count = 0

        var elements = [Int]()

        _ = Observable.generate(initialState: 0, condition: { _ in true }) { x in
            count += 1
            return x + 1
            }
            .take(4)
            .subscribe(onNext: { x in
                elements.append(x)
            })

        XCTAssertEqual(elements, [0, 1, 2, 3])
        XCTAssertEqual(count, 3)
    }

    #if TRACE_RESOURCES
        func testGenerateReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.generate(initialState: 0, condition: { _ in false }, scheduler: testScheduler) { (x: Int) -> Int in
                return x
            }.subscribe()
            testScheduler.start()
        }

        func testGenerateReleasesResourcesOnError() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.generate(initialState: 0, condition: { _ in false }, scheduler: testScheduler) { _ -> Int in
                throw testError
            }.subscribe()
            testScheduler.start()
        }
    #endif
}
