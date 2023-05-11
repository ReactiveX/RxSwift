//
//  Observable+ConcurrencyTests.swift
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
class ObservableConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ObservableConcurrencyTests {
    func testAwaitsValuesAndFinishes() async {
        let observable = Observable
            .from(1...10)

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

    func testAwaitsValuesAndErrors() async {
        let driver = Observable
            .from(1...10)
            .map { n -> Int in
                if n > 5 {
                    throw RxError.unknown
                }

                return n
            }

        var values = [Int]()

        do {
            for try await value in driver.values {
                values.append(value)
            }
        } catch {
            XCTAssertEqual(values, Array(1...5), "Expected to emit familure after 5 items")
        }
    }
    
    func testThrowsCancellationErrorWithoutEvents() async throws {
        let observable = Observable<Void>.never()
        Task {
            do {
                for try await _ in observable.values {
                    //
                }
                XCTFail("Should not proceed beyond try")
            } catch {
                XCTAssertTrue(Task.isCancelled)
                XCTAssertTrue(error is CancellationError)
            }
        }.cancel()
    }

    func testNotThrowingCancellation() async throws {
        let observable = Observable.from(1...10)
        let task = Task {
            do {
                var values = [Int]()
                for try await value in observable.values {
                    values.append(value)
                }
                XCTAssertTrue(values == Array(1...10))
            } catch {
                XCTFail("Should not throw CancellationError")
            }
        }
        try await Task.sleep(nanoseconds: 1_000_000)
        task.cancel()
    }

}
#endif
