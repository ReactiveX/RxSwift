//
//  PrimitiveSequence+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if swift(>=5.5) && canImport(_Concurrency) && !os(Linux)
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension PrimitiveSequenceType where Trait == SingleTrait {
    /// Allows awaiting the success or failure of this `Single`
    /// asynchronously via Swift's concurrency features (`async/await`)
    ///
    /// A sample usage would look like so:
    ///
    /// ```swift
    /// do {
    ///     let value = try await single.value
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    var value: Element {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                _ = self.subscribe(
                    onSuccess: { continuation.resume(returning: $0) },
                    onFailure: { continuation.resume(throwing: $0) }
                )
            }
        }
    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension PrimitiveSequenceType where Trait == MaybeTrait {
    /// Allows awaiting the success or failure of this `Maybe`
    /// asynchronously via Swift's concurrency features (`async/await`)
    ///
    /// If the `Maybe` completes without emitting a value, it would return
    /// a `nil` value to indicate so.
    ///
    /// A sample usage would look like so:
    ///
    /// ```swift
    /// do {
    ///     let value = try await maybe.value // Element?
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    var value: Element? {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                var didEmit = false
                _ = self.subscribe(
                    onSuccess: { value in
                        didEmit = true
                        continuation.resume(returning: value)
                    },
                    onError: { error in continuation.resume(throwing: error) },
                    onCompleted: {
                        guard !didEmit else { return }
                        continuation.resume(returning: nil)
                    }
                )
            }
        }
    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Never {
    /// Allows awaiting the success or failure of this `Completable`
    /// asynchronously via Swift's concurrency features (`async/await`)
    ///
    /// Upon completion, a `Void` will be returned
    ///
    /// A sample usage would look like so:
    ///
    /// ```swift
    /// do {
    ///     let value = try await completable.value // Void
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    var value: Void {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                _ = self.subscribe(
                    onCompleted: { continuation.resume() },
                    onError: { error in continuation.resume(throwing: error) }
                )
            }
        }
    }
}
#endif
