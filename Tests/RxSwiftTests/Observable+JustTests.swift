//
//  Observable+JustTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableJustTest : RxTest {
}

extension ObservableJustTest {
    func testJust_Immediate() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            return Observable.just(42)
        }

        XCTAssertEqual(res.events, [
            next(200, 42),
            completed(200)
            ])
    }

    func testJust_Basic() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start {
            return Observable.just(42, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            next(201, 42),
            completed(202)
            ])
    }

    func testJust_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let res = scheduler.start(disposed: 200) {
            return Observable.just(42, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            ])
    }

    func testJust_DisposeAfterNext() {
        let scheduler = TestScheduler(initialClock: 0)

        let d = SingleAssignmentDisposable()

        let res = scheduler.createObserver(Int.self)

        scheduler.scheduleAt(100) {
            let subscription = Observable.just(42, scheduler: scheduler).subscribe { e in
                res.on(e)

                switch e {
                case .next:
                    d.dispose()
                default:
                    break
                }
            }

            d.setDisposable(subscription)
        }

        scheduler.start()

        XCTAssertEqual(res.events, [
            next(101, 42)
            ])
    }

    func testJust_DefaultScheduler() {
        let res = try! Observable.just(42, scheduler: MainScheduler.instance)
            .toBlocking()
            .toArray()

        XCTAssertEqual(res, [
            42
            ])
    }

    func testJust_CompilesInMap() {
        _ = (1 as Int?).map(Observable.just)
    }

    #if TRACE_RESOURCES
        func testJustReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).subscribe()
        }
        #endif

        #if TRACE_RESOURCES
        func testJustSchdedulerReleasesResourcesOnComplete() {
            let testScheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1, scheduler: testScheduler).subscribe()
            testScheduler.start()
        }
    #endif
}
