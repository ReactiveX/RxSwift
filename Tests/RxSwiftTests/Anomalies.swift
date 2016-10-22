//
//  Anomalies.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/22/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxTests
import XCTest

/**
 Makes sure github anomalies and edge cases don't surface up again.
 */
class AnomaliesTest: RxTest {
}

extension AnomaliesTest {
    func test936() {
        let expectation = self.expectationWithDescription("wait until sequence completes")

        let queue = dispatch_queue_create(
            "Test",
            DISPATCH_QUEUE_CONCURRENT // commenting this to use a serial queue remove the issue
        )

        let scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: queue)

        func makeSequence(label: String, period: RxTimeInterval) -> Observable<Int> {
            return Observable<Int>
                .interval(period, scheduler: scheduler)
                .shareReplay(1)
        }

        let _ = makeSequence("main", period: 1.0)
            .flatMapLatest { (index: Int) -> Observable<(Int, Int)> in
                return makeSequence("nested", period: 0.2).map { (index, $0) }
            }
            .take(10)
            .mapWithIndex { ($1, $0.0, $0.1) }
            .subscribe(
                onNext: { _ in },
                onCompleted: {
                    expectation.fulfill()
                } 
        )
        
        waitForExpectationsWithTimeout(20.0) { (e) in
            XCTAssertNil(e)
        }
    }
}
