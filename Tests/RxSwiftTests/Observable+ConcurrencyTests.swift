//
//  Observable+ConcurrencyTests.swift
//  Tests
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
import Dispatch
import RxSwift
import XCTest
import RxTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class ObservableConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ObservableConcurrencyTests {
    func testAwaitsValuesAndFinishes() {
        let observable = Observable
            .from(1...10)

        Task {
            var values = [Int]()

            do {
                for try await value in observable.values {
                    values.append(value)
                }

                XCTAssertEqual(values, Array(1...10))
            } catch {
                XCTFail("Expected to not emit failure")
            }
        }
    }

    func testAwaitsValuesAndErrors() {
        let driver = Observable
            .from(1...10)
            .map { n -> Int in
                if n > 5 {
                    throw RxError.unknown
                }

                return n
            }

        Task {
            var values = [Int]()

            do {
                for try await value in driver.values {
                    values.append(value)
                }
            } catch {
                XCTAssertEqual(values, Array(1...5), "Expected to emit familure after 5 items")
            }
        }
    }
}
#endif
