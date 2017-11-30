//
//  Observable+RangeTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableRangeTest : RxTest {
}

extension ObservableRangeTest {
    func testRange_Boundaries() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            Observable.range(start: Int.max, count: 1, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, Int.max),
            .completed(202)
            ])
    }

    func testRange_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(disposed: 204) {
            Observable.range(start: -10, count: 5, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, -10),
            .next(202, -9),
            .next(203, -8)
            ])
    }

    #if TRACE_RESOURCES
        func testRangeSchedulerReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.range(start: 0, count: 1, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }

        func testRangeReleasesResourcesOnComplete() {
            _ = Observable<Int>.range(start: 0, count: 1).subscribe()
        }
    #endif
}
