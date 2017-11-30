//
//  Observable+OptionalTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableOptionalTest : RxTest {
}

extension ObservableOptionalTest {
    func testFromOptionalSome_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.some(5))
        }

        XCTAssertEqual(res.events, [
            .next(200, 5),
            .completed(200)
            ])
    }

    func testFromOptionalNone_immediate() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.none)
        }

        XCTAssertEqual(res.events, [
            .completed(200)
            ])
    }

    func testFromOptionalSome_basic_testScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.some(5), scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .next(201, 5),
            .completed(202)
            ])
    }

    func testFromOptionalNone_basic_testScheduler() {
        let scheduler = TestScheduler(initialClock: 0)
        let res = scheduler.start {
            Observable.from(optional: Optional<Int>.none, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .completed(201)
            ])
    }

    #if TRACE_RESOURCES
        func testFromOptionalScheduler1ReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.from(optional: 1 as Int?, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }

        func testFromOptionalScheduler2ReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.from(optional: nil as Int?, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }

        func testFromOptional1ReleasesResourcesOnComplete() {
            _ = Observable<Int>.from(optional: 1 as Int?).subscribe()
        }

        func testFromOptional2ReleasesResourcesOnComplete() {
            _ = Observable<Int>.from(optional: nil as Int?).subscribe()
        }
    #endif
}
