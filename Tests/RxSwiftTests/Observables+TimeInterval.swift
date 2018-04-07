//
//  Observables+TimeInterval.swift
//  Rx
//
//  Created by Ayal Spitz on 4/6/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation

import XCTest
import RxSwift
import RxTest

class ObservableTimeIntervalTest : RxTest {
}

extension ObservableTimeIntervalTest {
    func testTimeInterval() {
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let observer = PrimitiveMockObserver<RxTimeInterval>()
        let expectCompleted = expectation(description: "It will complete")
        
        let d = Observable<Int64>.interval(1, scheduler: scheduler)
            .takeWhile { $0 < 10 }
            .timeInterval()
            .map { $0.rounded(.toNearestOrAwayFromZero)}
            .subscribe(onNext: { t in
            observer.on(.next(t))
        }, onCompleted: {
            expectCompleted.fulfill()
        })
        
        defer {
            d.dispose()
        }
        
        waitForExpectations(timeout: 12.0) { e in
            XCTAssert(e == nil, "Did not complete")
        }
        
        let cleanResources = expectation(description: "Clean resources")
        
        _ = scheduler.schedule(()) { _ in
            cleanResources.fulfill()
            return Disposables.create()
        }
        
        waitForExpectations(timeout: 1.0) { e in
            XCTAssert(e == nil, "Did not clean up")
        }
        
        let correct = Recorded.events(
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0),
            .next(0, 1.0)
        )
        
        XCTAssertTrue(observer.events.count == 10)
        XCTAssertEqual(observer.events, correct)
    }
}
