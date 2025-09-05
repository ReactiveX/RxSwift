//
//  Infallible+ConcurrencyTests.swift
//  Tests
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.6) && canImport(_Concurrency) && !os(Linux)
import Dispatch
import RxSwift
import XCTest
import RxTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class InfallibleConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension InfallibleConcurrencyTests {
    func testAwaitsValuesAndFinishes() async {
        let infallible = Infallible
            .from(1...10)

        var values = [Int]()

        for await value in infallible.values {
            values.append(value)
        }

        XCTAssertEqual(values, Array(1...10))
    }

    func testCreateInfalliableFromAsync() async throws {
        var expectedValues = [Int]()
        let randomValue: () async -> Int = {
            let value = Int.random(in: 100...100000)
            expectedValues.append(value)
            return value
        }

        let infallible = Infallible<Int>.create { observer in
            for _ in 1...10 {
                observer(await randomValue())
            }
        }

        let values = try infallible.toBlocking().toArray()
        XCTAssertEqual(values, expectedValues)
    }
}
#endif
