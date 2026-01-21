//
//  Observable+ConcurrencyTests.swift
//  Tests
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.7)
import Dispatch
import RxSwift
import RxTest
import XCTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class ObservableConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension ObservableConcurrencyTests {
    func testAwaitsValuesAndFinishes() async {
        let observable = Observable
            .from(1 ... 10)

        var values = [Int]()

        do {
            for try await value in observable.values {
                values.append(value)
            }

            XCTAssertEqual(values, Array(1 ... 10))
        } catch {
            XCTFail("Expected to not emit failure")
        }
    }

    func testAwaitsValuesAndErrors() async {
        let driver = Observable
            .from(1 ... 10)
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
            XCTAssertEqual(values, Array(1 ... 5), "Expected to emit familure after 5 items")
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
        let observable = Observable.from(1 ... 10)
        let task = Task {
            do {
                var values = [Int]()
                for try await value in observable.values {
                    values.append(value)
                }
                XCTAssertTrue(values == Array(1 ... 10))
            } catch {
                XCTFail("Should not throw CancellationError")
            }
        }
        try await Task.sleep(nanoseconds: 1_000_000)
        task.cancel()
    }

    // MARK: - AsyncSequence.asObservable() Tests

    func testAsyncSequenceToObservable() async {
        let asyncSequence = AsyncStream<Int> { continuation in
            for i in 1 ... 5 {
                continuation.yield(i)
            }
            continuation.finish()
        }

        let expectation = XCTestExpectation(description: "Observable completes with all values")
        var values = [Int]()

        let disposable = asyncSequence.asObservable().subscribe(
            onNext: { value in
                values.append(value)
            },
            onCompleted: {
                XCTAssertEqual(values, [1, 2, 3, 4, 5])
                expectation.fulfill()
            },
        )

        await fulfillment(of: [expectation], timeout: 5.0)
        disposable.dispose()
    }

    func testAsyncSequenceToObservableRunsOnBackgroundThread() async {
        let asyncSequence = AsyncStream<Int> { continuation in
            for i in 1 ... 3 {
                continuation.yield(i)
            }
            continuation.finish()
        }

        let expectation = XCTestExpectation(description: "Observable runs on background thread")
        var observedOnMainThread = false

        // Subscribe from main thread
        let disposable = await MainActor.run {
            asyncSequence.asObservable().subscribe(
                onNext: { _ in
                    // AsyncSequence iteration should NOT be on main thread
                    if Thread.isMainThread {
                        observedOnMainThread = true
                    }
                },
                onCompleted: {
                    // The iteration should have happened on background thread
                    XCTAssertFalse(observedOnMainThread, "AsyncSequence iteration should not run on main thread")
                    expectation.fulfill()
                },
            )
        }

        await fulfillment(of: [expectation], timeout: 5.0)
        disposable.dispose()
    }

    func testAsyncSequenceToObservableWithError() async {
        struct TestError: Error {}

        let asyncSequence = AsyncThrowingStream<Int, Error> { continuation in
            continuation.yield(1)
            continuation.yield(2)
            continuation.finish(throwing: TestError())
        }

        let expectation = XCTestExpectation(description: "Observable handles error")
        var receivedError: Error?
        var values = [Int]()

        let disposable = asyncSequence.asObservable().subscribe(
            onNext: { value in
                values.append(value)
            },
            onError: { error in
                receivedError = error
                expectation.fulfill()
            },
        )

        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertEqual(values, [1, 2])
        XCTAssertTrue(receivedError is TestError)
        disposable.dispose()
    }

    func testAsyncSequenceToObservableCancellation() async {
        let expectation = XCTestExpectation(description: "Observable handles cancellation")
        var completed = false

        let asyncSequence = AsyncStream<Int> { continuation in
            continuation.onTermination = { _ in
                expectation.fulfill()
            }
            // Never yield values, just wait for cancellation
        }

        let disposable = asyncSequence.asObservable().subscribe(
            onNext: { _ in },
            onCompleted: {
                completed = true
            },
        )

        // Cancel immediately
        disposable.dispose()

        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertFalse(completed, "Should not complete, should be cancelled")
    }

    func testAsyncSequenceToObservableWithPriority() async {
        let asyncSequence = AsyncStream<Int> { continuation in
            Task {
                continuation.yield(1)
                continuation.finish()
            }
        }

        let expectation = XCTestExpectation(description: "Observable works with priority parameter")
        var receivedValue = false

        let disposable = asyncSequence.asObservable(priority: .userInitiated).subscribe(
            onNext: { _ in
                receivedValue = true
            },
            onCompleted: {
                XCTAssertTrue(receivedValue)
                expectation.fulfill()
            },
        )

        await fulfillment(of: [expectation], timeout: 5.0)
        disposable.dispose()
    }
}
#endif
