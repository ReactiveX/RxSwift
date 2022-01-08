//
//  Infallible+ConcurrencyTests.swift
//  Tests
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5) && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
import Dispatch
import RxSwift
import XCTest
import RxTest

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
class InfallibleConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension InfallibleConcurrencyTests {
    func testAwaitsValuesAndFinishes() {
        let infallible = Infallible
            .from(1...10)

        Task {
            var values = [Int]()

            do {
                for await value in infallible.values {
                    values.append(value)
                }

                XCTAssertEqual(values, Array(1...10))
            }
        }
    }
}
#endif
