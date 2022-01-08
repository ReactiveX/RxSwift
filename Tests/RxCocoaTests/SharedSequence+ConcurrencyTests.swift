//
//  SharedSequence+ConcurrencyTests.swift
//  Tests
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
import Dispatch
import RxSwift
import RxCocoa
import XCTest
import RxTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class SharedSequenceConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SharedSequenceConcurrencyTests {
    @MainActor func testAwaitsValuesAndFinishes() {
        let driver = Driver.from(1...10)

        Task {
            var values = [Int]()

            for await value in driver.values {
                values.append(value)
            }

            XCTAssertEqual(values, Array(1...10))
        }
    }
}
#endif
