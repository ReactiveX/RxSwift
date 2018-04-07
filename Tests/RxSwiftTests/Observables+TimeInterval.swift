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
        // Test peramiters
        let timeInterval = 1.0
        let numberOfIntervals = 10
        let totalTime = timeInterval * Double(numberOfIntervals) + timeInterval
        
        let scheduler = SerialDispatchQueueScheduler(qos: .default)
        let observer = PrimitiveMockObserver<RxTimeInterval>()
        let expectCompleted = expectation(description: "It will complete")
        
        let d = Observable<Int64>.interval(timeInterval, scheduler: scheduler)
            .takeWhile { $0 < numberOfIntervals }
            .timeInterval(roundRule: .toNearestOrAwayFromZero)
            .subscribe(onNext: { t in
                observer.on(.next(t))
            }, onCompleted: {
                expectCompleted.fulfill()
            })
        
        defer {
            d.dispose()
        }
        
        waitForExpectations(timeout: totalTime) { e in
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
        
        // Build correct observer
        let correct = PrimitiveMockObserver<RxTimeInterval>()
        for _ in 0..<numberOfIntervals {
            correct.on(.next(1.0))
        }
        
        XCTAssertTrue(observer.events.count == numberOfIntervals)
        XCTAssertEqual(observer.events, correct.events)
    }
}
