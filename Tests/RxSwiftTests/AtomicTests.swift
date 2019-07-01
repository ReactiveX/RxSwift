//
//  AtomicTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/29/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import XCTest
import Dispatch

#if true
typealias AtomicPrimitive = AtomicInt
#else
private struct AtomicIntSanityCheck {
    var atom: Int32 = 0

    init() {
    }

    init(_ atom: Int32) {
        self.atom = atom
    }

    mutating func add(_ value: Int32) -> Int32 {
        defer { self.atom += value }
        return self.atom
    }

    mutating func sub(_ value: Int32) -> Int32 {
        defer { self.atom -= value }
        return self.atom
    }

    mutating func fetchOr(_ value: Int32) -> Int32 {
        defer { self.atom |= value }
        return self.atom
    }

    func load() -> Int32 {
        return self.atom
    }
}
private typealias AtomicPrimitive = AtomicIntSanityCheck
#endif

class AtomicTests: RxTest {}

extension AtomicTests {
    func testAtomicInitialValue() {
        let atomic = AtomicPrimitive(4)
        XCTAssertEqual(globalLoad(atomic), 4)
    }

    func testAtomicInitialDefaultValue() {
        let atomic = AtomicPrimitive()
        XCTAssertEqual(globalLoad(atomic), 0)
    }
}

extension AtomicTests {
    private static let repeatCount = 100
    private static let concurrency = 8

    func testFetchOrSetsBits() {
        let atomic = AtomicPrimitive()
        XCTAssertEqual(fetchOr(atomic, 0), 0)
        XCTAssertEqual(fetchOr(atomic, 4), 0)
        XCTAssertEqual(fetchOr(atomic, 8), 4)
        XCTAssertEqual(fetchOr(atomic, 0), 12)
    }

    func testFetchOrConcurrent() {
        let queue = DispatchQueue.global(qos: .default)
        for _ in 0 ..< AtomicTests.repeatCount {
            let atomic = AtomicPrimitive(0)

            let counter = AtomicPrimitive(0)

            var expectations = [XCTestExpectation]()

            for _ in 0 ..< AtomicTests.concurrency {
                let expectation = self.expectation(description: "wait until operation completes")
                queue.async {
                    while globalLoad(atomic) == 0 {}

                    if fetchOr(atomic, -1) == 1 {
                        globalAdd(counter, 1)
                    }

                    expectation.fulfill()
                }
                expectations.append(expectation)
            }
            fetchOr(atomic, 1)

            #if os(Linux)
            self.waitForExpectations(timeout: 1.0) { _ in }
            #else
            XCTWaiter().wait(for: expectations, timeout: 1.0)
            #endif
            XCTAssertEqual(globalLoad(counter), 1)
        }
    }

    func testAdd() {
        let atomic = AtomicPrimitive(0)
        XCTAssertEqual(globalAdd(atomic, 4), 0)
        XCTAssertEqual(globalAdd(atomic, 3), 4)
        XCTAssertEqual(globalAdd(atomic, 10), 7)
    }

    func testAddConcurrent() {
        let queue = DispatchQueue.global(qos: .default)
        for _ in 0 ..< AtomicTests.repeatCount {
            let atomic = AtomicPrimitive(0)

            let counter = AtomicPrimitive(0)

            var expectations = [XCTestExpectation]()

            for _ in 0 ..< AtomicTests.concurrency {
                let expectation = self.expectation(description: "wait until operation completes")
                queue.async {
                    while globalLoad(atomic) == 0 {}

                    globalAdd(counter, 1)

                    expectation.fulfill()
                }
                expectations.append(expectation)
            }
            fetchOr(atomic, 1)

            #if os(Linux)
            waitForExpectations(timeout: 1.0) { _ in }
            #else
            XCTWaiter().wait(for: expectations, timeout: 1.0)
            #endif

            XCTAssertEqual(globalLoad(counter), 8)
        }
    }

    func testSub() {
        let atomic = AtomicPrimitive(0)
        XCTAssertEqual(sub(atomic, -4), 0)
        XCTAssertEqual(sub(atomic, -3), 4)
        XCTAssertEqual(sub(atomic, -10), 7)
    }

    func testSubConcurrent() {
        let queue = DispatchQueue.global(qos: .default)
        for _ in 0 ..< AtomicTests.repeatCount {
            let atomic = AtomicPrimitive(0)

            let counter = AtomicPrimitive(0)

            var expectations = [XCTestExpectation]()

            for _ in 0 ..< AtomicTests.concurrency {
                let expectation = self.expectation(description: "wait until operation completes")
                queue.async {
                    while globalLoad(atomic) == 0 {}

                    sub(counter, 1)

                    expectation.fulfill()
                }
                expectations.append(expectation)
            }
            fetchOr(atomic, 1)

            #if os(Linux)
            waitForExpectations(timeout: 1.0) { _ in }
            #else
            XCTWaiter().wait(for: expectations, timeout: 1.0)
            #endif

            XCTAssertEqual(globalLoad(counter), -8)
        }
    }
}
