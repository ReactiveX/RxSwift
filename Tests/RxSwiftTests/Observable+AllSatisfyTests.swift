//
//  Observable+AllSatisfyTests.swift
//  Rx
//
//  Created by Anton Nazarov on 14/06/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableAllSatisfyTests: RxTest {
    private var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        scheduler = nil
        super.tearDown()
    }
}

extension ObservableAllSatisfyTests {
    func testAllSatisfySuccessTrue() {
        // Given
        let scheduler = TestScheduler(initialClock: 0)
        let notEmittedEventsCount = 2
        let expectedCompletionTime = 600
        var invoked = 0
        let expectedNextEvents = Recorded.events([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11)
        ])
        let source = scheduler.createHotObservable(expectedNextEvents + [.completed(expectedCompletionTime)])
        // When
        let res = scheduler.start {
            source.allSatisfy {
                invoked += 1
                return $0 < 20
            }
            .asObservable()
        }
        // Expect
        XCTAssertEqual(res.events, [.next(expectedCompletionTime, true), .completed(expectedCompletionTime)])
        XCTAssertEqual(source.subscriptions, [Subscription(Defaults.subscribed, expectedCompletionTime)])
        XCTAssertEqual(invoked, expectedNextEvents.count - notEmittedEventsCount)
    }

    func testAllSatisfySuccessFalse() {
        // Given
        let scheduler = TestScheduler(initialClock: 0)
        let expectedCompletionTime = 230
        var invoked = 0
        let source = scheduler.createHotObservable([
            .next(110, 1),
            .next(180, 2),
            .next(expectedCompletionTime, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7),
            .next(450, 8),
            .next(470, 9),
            .next(560, 10),
            .next(580, 11),
            .completed(600)
        ])
        // When
        let res = scheduler.start {
            source.allSatisfy {
                invoked += 1
                return $0 > 20
            }
            .asObservable()
        }
        // Expect
        XCTAssertEqual(res.events, [.next(expectedCompletionTime, false), .completed(expectedCompletionTime)])
        XCTAssertEqual(source.subscriptions, [Subscription(Defaults.subscribed, expectedCompletionTime)])
        XCTAssertEqual(invoked, 1)
    }

    func testAllSatisfyFailure() {
        // Given
        let scheduler = TestScheduler(initialClock: 0)
        let expectedErrorTime = 400
        let notEmittedEventsCount = 2
        var invoked = 0
        let expectedNextEvents = Recorded.events([
            .next(110, 1),
            .next(180, 2),
            .next(230, 3),
            .next(270, 4),
            .next(340, 5),
            .next(380, 6),
            .next(390, 7)
        ])
        let source = scheduler.createHotObservable(
            expectedNextEvents + [
                .error(expectedErrorTime, testError),
                .next(470, 9),
                .next(560, 10),
                .next(580, 11),
                .completed(600)
            ]
        )
        // When
        let res = scheduler.start {
            source.allSatisfy {
                invoked += 1
                return $0 < 20
            }
            .asObservable()
        }
        // Expect
        XCTAssertEqual(res.events, [.error(expectedErrorTime, testError)])
        XCTAssertEqual(source.subscriptions, [Subscription(Defaults.subscribed, expectedErrorTime)])
        XCTAssertEqual(invoked, expectedNextEvents.count - notEmittedEventsCount)
    }

    #if TRACE_RESOURCES
    func testAllSatisfyReleasesResourcesOnSuccessTrue() {
        _ = Observable.just(1).allSatisfy { _ in true }.subscribe()
    }

    func testAllSatisfyReleasesResourcesOnSuccessFalse() {
        _ = Observable.just(1).allSatisfy { _ in false }.subscribe()
    }

    func testAllSatisfyReleasesResourcesOnFailure() {
        _ = Observable.error(testError).allSatisfy { $0 > 0 }.subscribe()
    }
    #endif
}
