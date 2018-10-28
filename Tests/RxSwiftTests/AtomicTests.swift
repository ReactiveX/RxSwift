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
import RxAtomic
typealias AtomicPrimitive = AtomicInt
#else
fileprivate struct AtomicIntSanityCheck {
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
fileprivate typealias AtomicPrimitive = AtomicIntSanityCheck
#endif

public class AtomicTests: XCTestCase {}

extension AtomicTests {
    func testAtomicInitialValue() {
        var atomic = AtomicPrimitive(4)
        XCTAssertEqual(atomic.load(), 4)
    }

    func testAtomicInitialDefaultValue() {
        var atomic = AtomicPrimitive()
        XCTAssertEqual(atomic.load(), 0)
    }
}

extension AtomicTests {
    private static let repeatCount = 100
    private static let concurrency = 8

    func testFetchOrSetsBits() {
        var atomic = AtomicPrimitive()
        XCTAssertEqual(atomic.fetchOr(0), 0)
        XCTAssertEqual(atomic.fetchOr(4), 0)
        XCTAssertEqual(atomic.fetchOr(8), 4)
        XCTAssertEqual(atomic.fetchOr(0), 12)
    }

    func testFetchOrConcurrent() {
        let queue = DispatchQueue.global(qos: .default)
        for _ in 0 ..< AtomicTests.repeatCount {
            var atomic = AtomicPrimitive(0)

            var counter = AtomicPrimitive(0)

            var expectations = [XCTestExpectation]()

            for _ in 0 ..< AtomicTests.concurrency {
                let expectation = self.expectation(description: "wait until operation completes")
                queue.async {
                    while atomic.load() == 0 {}

                    if atomic.fetchOr(-1) == 1 {
                        counter.add(1)
                    }

                    expectation.fulfill()
                }
                expectations.append(expectation)
            }
            atomic.fetchOr(1)

            #if os(Linux)
            self.waitForExpectations(timeout: 1.0) { _ in }
            #else
            XCTWaiter().wait(for: expectations, timeout: 1.0)
            #endif
            XCTAssertEqual(counter.load(), 1)
        }
    }

    func testAdd() {
        var atomic = AtomicPrimitive(0)
        XCTAssertEqual(atomic.add(4), 0)
        XCTAssertEqual(atomic.add(3), 4)
        XCTAssertEqual(atomic.add(10), 7)
    }

    func testAddConcurrent() {
        let queue = DispatchQueue.global(qos: .default)
        for _ in 0 ..< AtomicTests.repeatCount {
            var atomic = AtomicPrimitive(0)

            var counter = AtomicPrimitive(0)

            var expectations = [XCTestExpectation]()

            for _ in 0 ..< AtomicTests.concurrency {
                let expectation = self.expectation(description: "wait until operation completes")
                queue.async {
                    while atomic.load() == 0 {}

                    counter.add(1)

                    expectation.fulfill()
                }
                expectations.append(expectation)
            }
            atomic.fetchOr(1)

            #if os(Linux)
            waitForExpectations(timeout: 1.0) { _ in }
            #else
            XCTWaiter().wait(for: expectations, timeout: 1.0)
            #endif

            XCTAssertEqual(counter.load(), 8)
        }
    }

    func testSub() {
        var atomic = AtomicPrimitive(0)
        XCTAssertEqual(atomic.sub(-4), 0)
        XCTAssertEqual(atomic.sub(-3), 4)
        XCTAssertEqual(atomic.sub(-10), 7)
    }

    func testSubConcurrent() {
        let queue = DispatchQueue.global(qos: .default)
        for _ in 0 ..< AtomicTests.repeatCount {
            var atomic = AtomicPrimitive(0)

            var counter = AtomicPrimitive(0)

            var expectations = [XCTestExpectation]()

            for _ in 0 ..< AtomicTests.concurrency {
                let expectation = self.expectation(description: "wait until operation completes")
                queue.async {
                    while atomic.load() == 0 {}

                    counter.sub(1)

                    expectation.fulfill()
                }
                expectations.append(expectation)
            }
            atomic.fetchOr(1)

            #if os(Linux)
            waitForExpectations(timeout: 1.0) { _ in }
            #else
            XCTWaiter().wait(for: expectations, timeout: 1.0)
            #endif

            XCTAssertEqual(counter.load(), -8)
        }
    }
}
