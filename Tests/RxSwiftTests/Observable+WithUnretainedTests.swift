//
//  Observable+WithUnretainedTests.swift
//  Tests
//
//  Created by Vincent Pradeilles on 01/01/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class WithUnretainedTests: XCTestCase {
    fileprivate var testClass: TestClass!
    var values: TestableObservable<Int>!
    var tupleValues: TestableObservable<(Int, String)>!
    let scheduler = TestScheduler(initialClock: 0)

    override func setUp() {
        super.setUp()

        testClass = TestClass()
        values = scheduler.createColdObservable([
            .next(210, 1),
            .next(215, 2),
            .next(220, 3),
            .next(225, 5),
            .next(230, 8),
            .completed(250)
        ])

        tupleValues = scheduler.createColdObservable([
            .next(210, (1, "a")),
            .next(215, (2, "b")),
            .next(220, (3, "c")),
            .next(225, (5, "d")),
            .next(230, (8, "e")),
            .completed(250)
        ])
    }

    func testObjectAttached() {
        let testClassId = testClass.id

        let correctValues: [Recorded<Event<String>>] = [
            .next(410, "\(testClassId), 1"),
            .next(415, "\(testClassId), 2"),
            .next(420, "\(testClassId), 3"),
            .next(425, "\(testClassId), 5"),
            .next(430, "\(testClassId), 8"),
            .completed(450)
        ]

        let res = scheduler.start {
            self.values
                .withUnretained(self.testClass)
                .map { "\($0.id), \($1)" }
        }

        XCTAssertEqual(res.events, correctValues)
    }

    func testObjectDeallocates() {
        _ = self.values
                .withUnretained(self.testClass)
                .subscribe()

        // Confirm the object can be deallocated
        XCTAssertTrue(testClass != nil)
        testClass = nil
        XCTAssertTrue(testClass == nil)
    }

    func testObjectDeallocatesSequenceCompletes() {
        let testClassId = testClass.id

        let correctValues: [Recorded<Event<String>>] = [
            .next(410, "\(testClassId), 1"),
            .next(415, "\(testClassId), 2"),
            .next(420, "\(testClassId), 3"),
            .completed(425)
        ]

        let res = scheduler.start {
            self.values
                .withUnretained(self.testClass)
                .do(onNext: { _, value in
                    // Release the object in the middle of the sequence
                    // to confirm it properly terminates the sequence
                    if value == 3 {
                        self.testClass = nil
                    }
                })
                .map { "\($0.id), \($1)" }
        }

        XCTAssertEqual(res.events, correctValues)
    }

    func testResultsSelector() {
        let testClassId = testClass.id

        let correctValues: [Recorded<Event<String>>] = [
            .next(410, "\(testClassId), 1, a"),
            .next(415, "\(testClassId), 2, b"),
            .next(420, "\(testClassId), 3, c"),
            .next(425, "\(testClassId), 5, d"),
            .next(430, "\(testClassId), 8, e"),
            .completed(450)
        ]

        let res = scheduler.start {
            self.tupleValues
                .withUnretained(self.testClass) { ($0, $1.0, $1.1) }
                .map { "\($0.id), \($1), \($2)" }
        }

        XCTAssertEqual(res.events, correctValues)
    }
}

private class TestClass {
    let id: String = UUID().uuidString
}
