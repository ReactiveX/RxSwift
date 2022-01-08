//
//  PrimitiveSequence+ConcurrencyTests.swift
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
class PrimitiveSequenceConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

// MARK: - Single
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
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
}

// MARK: - Maybe
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
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
}

// MARK: - Completable
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
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
}
#endif

