//
//  Infallible+ConcurrencyTests.swift
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
class InfallibleConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
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
    
    func testInfailablelEmitsElementFromAwait() async throws {
        let infailable = Infallible.from {
            return "Hello"
        }
        
        var didLoop = false
        
        for try await value in infailable.values {
            XCTAssertEqual(value, "Hello")
            didLoop = true
        }
        
        XCTAssertTrue(didLoop)
    }
}
#endif
