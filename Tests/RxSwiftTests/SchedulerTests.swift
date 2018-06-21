//
//  SchedulerTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/22/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest
#if os(Linux)
import Glibc
import Dispatch
#endif

import struct Foundation.Date

class ConcurrentDispatchQueueSchedulerTests: RxTest {
    func createScheduler() -> SchedulerType {
        return ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    }
}

final class SerialDispatchQueueSchedulerTests: RxTest {
    func createScheduler() -> SchedulerType {
        return SerialDispatchQueueScheduler(qos: .userInitiated)
    }
}

class OperationQueueSchedulerTests: RxTest {
}

extension ConcurrentDispatchQueueSchedulerTests {
    func test_scheduleRelative() {
        let expectScheduling = expectation(description: "wait")
        let start = Date()

        var interval = 0.0

        let scheduler = self.createScheduler()

        _ = scheduler.scheduleRelative(1, dueTime: 0.5) { (_) -> Disposable in
            interval = Date().timeIntervalSince(start)
            expectScheduling.fulfill()
            return Disposables.create()
        }

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
        }

        XCTAssertEqual(interval, 0.5, accuracy: 0.2)
    }

    func test_scheduleRelativeCancel() {
        let expectScheduling = expectation(description: "wait")
        let start = Date()

        var interval = 0.0

        let scheduler = self.createScheduler()

        let disposable = scheduler.scheduleRelative(1, dueTime: 0.1) { (_) -> Disposable in
            interval = Date().timeIntervalSince(start)
            expectScheduling.fulfill()
            return Disposables.create()
        }
        disposable.dispose()

        DispatchQueue.main.asyncAfter (deadline: .now() + .milliseconds(200)) {
            expectScheduling.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            XCTAssertNil(error)
        }

        XCTAssertEqual(interval, 0.0, accuracy: 0.0)
    }

    func test_schedulePeriodic() {
        let expectScheduling = expectation(description: "wait")
        let start = Date()
        var times = [Date]()

        let scheduler = self.createScheduler()

        let disposable = scheduler.schedulePeriodic(0, startAfter: 0.2, period: 0.3) { (state) -> Int in
            times.append(Date())
            if state == 1 {
                expectScheduling.fulfill()
            }
            return state + 1
        }

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
        }

        disposable.dispose()

        XCTAssertEqual(times.count, 2)
        XCTAssertEqual(times[0].timeIntervalSince(start), 0.2, accuracy: 0.1)
        XCTAssertEqual(times[1].timeIntervalSince(start), 0.5, accuracy: 0.2)
    }

    func test_schedulePeriodicCancel() {
        let expectScheduling = expectation(description: "wait")
        var times = [Date]()

        let scheduler = self.createScheduler()

        let disposable = scheduler.schedulePeriodic(0, startAfter: 0.2, period: 0.3) { (state) -> Int in
            times.append(Date())
            return state + 1
        }

        disposable.dispose()

        DispatchQueue.main.asyncAfter (deadline: .now() + .milliseconds(300)) {
            expectScheduling.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
        }

        XCTAssertEqual(times.count, 0)
    }
}

extension OperationQueueSchedulerTests {
    func test_scheduleWithPriority() {
        let expectScheduling = expectation(description: "wait")

        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1

        let highPriority = OperationQueueScheduler.init(operationQueue: operationQueue, queuePriority: .high)
        let lowPriority = OperationQueueScheduler.init(operationQueue: operationQueue, queuePriority: .low)

        var times = [String]()

        _ = highPriority.schedule(Int.self) { (value) -> Disposable in
            Thread.sleep(forTimeInterval: 0.4)
            times.append("HIGH")

            return Disposables.create()
            }

        _ = lowPriority.schedule(Int.self) { (value) -> Disposable in
            Thread.sleep(forTimeInterval: 1)
            times.append("LOW")

            expectScheduling.fulfill()

            return Disposables.create()
            }

        _ = highPriority.schedule(Int.self) { (value) -> Disposable in
            Thread.sleep(forTimeInterval: 0.2)
            times.append("HIGH")

            return Disposables.create()
            }

        waitForExpectations(timeout: 4.0) { error in
            XCTAssertNil(error)
        }

        XCTAssertEqual(["HIGH", "HIGH", "LOW"], times)
    }
}
