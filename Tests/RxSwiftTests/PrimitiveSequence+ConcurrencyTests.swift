//
//  PrimitiveSequence+ConcurrencyTests.swift
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
import RxBlocking

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class PrimitiveSequenceConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

// MARK: - Single
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension PrimitiveSequenceConcurrencyTests {
    func testSingleEmitsElement() async throws {
        let single = Single.just("Hello")

        do {
            let value = try await single.value
            XCTAssertEqual(value, "Hello")
        } catch {
            XCTFail("Should not throw an error")
        }
    }

    func testSingleThrowsError() async throws {
        let single = Single<String>.error(RxError.unknown)

        do {
            _ = try await single.value
            XCTFail("Should not proceed beyond try")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func testSingleThrowsCancellationWithoutEvents() async throws {
        let single = Single<Void>.never()

        Task {
            do {
                try await single.value
                XCTFail("Should not proceed beyond try")
            } catch {
                XCTAssertTrue(Task.isCancelled)
                XCTAssertTrue(error is CancellationError)
            }
        }.cancel()
    }

    func testSingleNotThrowingCancellation() async throws {
        let single = Single.just(())

        let task = Task {
            do {
                try await single.value
                XCTAssertTrue(true)
            } catch {
                XCTFail()
            }
        }

        try await Task.sleep(nanoseconds: 1_000_000)
        task.cancel()
    }

    func testCreateSingleFromAsync() {
        let randomResult = Int.random(in: 100...100000)
        let work: () async throws -> Int = { randomResult }

        let single = Single.create {
            try await work()
        }

        XCTAssertEqual(
            try! single.toBlocking().toArray(),
            [randomResult]
        )
    }

    /// A previous implementation of the `Single` to swift concurrency bridge had a bug where it would sometimes call the continuation twice.
    /// The current number of iterations is a sweet spot to not make the tests too slow while still catching the bug in most runs.
    /// If you are debugging this issue you might want to increase the iterations and/or run this test repeatedly.
    func testSingleContinuationIsNotResumedTwice() {
        let expectation = XCTestExpectation()
        let iterations = 10000
        for i in 0 ..< iterations {
            DispatchQueue.global(qos: .userInitiated).async {
                let single = Single<Int>.create { observer in
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.005) {
                        observer(.success(42))
                    }
                    return Disposables.create()
                }

                let task = Task {
                    _ = try await single.value
                }

                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.005) {
                    task.cancel()
                }

                self.sleep(Double.random(in: 0.004...0.006))

                if i == iterations - 1 {
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}

// MARK: - Maybe
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension PrimitiveSequenceConcurrencyTests {
    func testMaybeEmitsElement() async throws {
        let maybe = Maybe.just("Hello")

        do {
            let value = try await maybe.value
            XCTAssertNotNil(value)
            XCTAssertEqual(value, "Hello")
        } catch {
            XCTFail("Should not throw an error")
        }
    }

    func testMaybeEmitsNilWithoutValue() async throws {
        let maybe = Maybe<String>.empty()

        do {
            let value = try await maybe.value
            XCTAssertNil(value)
        } catch {
            XCTFail("Should not throw an error")
        }
    }

    func testMaybeThrowsError() async throws {
        let maybe = Maybe<String>.error(RxError.unknown)

        do {
            _ = try await maybe.value
            XCTFail("Should not proceed beyond try")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func testMaybeThrowsCancellationWithoutEvents() async throws {
        let maybe = Maybe<Void>.never()

        Task {
            do {
                try await maybe.value
                XCTFail("Should not proceed beyond try")
            } catch {
                XCTAssertTrue(Task.isCancelled)
                XCTAssertTrue(error is CancellationError)
            }
        }.cancel()
    }

    func testMaybeNotThrowingCancellationWhenCompleted() async throws {
        let maybe = Maybe<Int>.empty()

        Task {
            do {
                let value = try await maybe.value
                XCTAssertNil(value)
            } catch {
                XCTFail("Should not throw an error")
            }
        }.cancel()
    }

    func testMaybeNotThrowingCancellation() async throws {
        let maybe = Maybe.just(())

        let task = Task {
            do {
                try await maybe.value
                XCTAssertTrue(true)
            } catch {
                XCTFail("Should not throw an error")
            }
        }

        try await Task.sleep(nanoseconds: 1_000_000)
        task.cancel()
    }

    /// A previous implementation of the `Single` to swift concurrency bridge had a bug where it would sometimes call the continuation twice.
    /// The current number of iterations is a sweet spot to not make the tests too slow while still catching the bug in most runs.
    /// If you are debugging this issue you might want to increase the iterations and/or run this test repeatedly.
    func testMaybeContinuationIsNotResumedTwice() {
        let expectation = XCTestExpectation()
        let iterations = 10000
        for i in 0 ..< iterations {
            DispatchQueue.global(qos: .userInitiated).async {
                let maybe = Maybe<Bool>.create { observer in
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.005) {
                        observer(.success(true))
                    }
                    return Disposables.create()
                }

                let task = Task {
                    _ = try await maybe.value
                }

                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.005) {
                    task.cancel()
                }

                self.sleep(Double.random(in: 0.004...0.006))

                if i == iterations - 1 {
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}

// MARK: - Completable
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension PrimitiveSequenceConcurrencyTests {
    func testCompletableEmitsVoidOnCompletion() async throws {
        let completable = Completable.empty()

        do {
            let value: Void = try await completable.value
            XCTAssert(value == ())
        } catch {
            XCTFail("Should not throw an error")
        }
    }

    func testCompletableThrowsError() async throws {
        let completable = Completable.error(RxError.unknown)

        do {
            _ = try await completable.value
            XCTFail("Should not proceed beyond try")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func testCompletableThrowsCancellationWithoutEvents() async throws {
        let completable = Completable.never()

        Task {
            do {
                try await completable.value
                XCTFail()
            } catch {
                XCTAssertTrue(Task.isCancelled)
                XCTAssertTrue(error is CancellationError)
            }
        }.cancel()
    }

    func testCompletableNotThrowingCancellation() async throws {
        let completable = Completable.empty()

        Task {
            do {
                try await completable.value
                XCTAssertTrue(true)
            } catch {
                XCTFail("Should not throw an error")
            }
        }.cancel()
    }

    /// A previous implementation of the `Single` to swift concurrency bridge had a bug where it would sometimes call the continuation twice.
    /// The current number of iterations is a sweet spot to not make the tests too slow while still catching the bug in most runs.
    /// If you are debugging this issue you might want to increase the iterations and/or run this test repeatedly.
    func testCompletableContinuationIsNotResumedTwice() {
        let expectation = XCTestExpectation()
        let iterations = 10000
        for i in 0 ..< iterations {
            DispatchQueue.global(qos: .userInitiated).async {
                let completable = Completable.create { observer in
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.005) {
                        observer(.completed)
                    }
                    return Disposables.create()
                }

                let task = Task {
                    _ = try await completable.value
                }

                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.005) {
                    task.cancel()
                }

                self.sleep(Double.random(in: 0.004...0.006))

                if i == iterations - 1 {
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}
#endif

