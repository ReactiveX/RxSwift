//
//  PrimitiveSequence+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if swift(>=5.6) && canImport(_Concurrency) && !os(Linux)
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
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
            let disposable = SingleAssignmentDisposable()
            return try await withTaskCancellationHandler(
                operation: {
                    try await withCheckedThrowingContinuation { continuation in
                        var didResume = false
                        disposable.setDisposable(
                            self.subscribe(
                                onSuccess: {
                                    didResume = true
                                    continuation.resume(returning: $0)
                                },
                                onFailure: {
                                    didResume = true
                                    continuation.resume(throwing: $0)
                                },
                                onDisposed: {
                                    guard !didResume else { return }
                                    continuation.resume(throwing: CancellationError())
                                }
                            )
                        )
                    }
                },
                onCancel: { [disposable] in
                    disposable.dispose()
                }
            )
        }
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
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
            let disposable = SingleAssignmentDisposable()
            return try await withTaskCancellationHandler(
                operation: {
                    try await withCheckedThrowingContinuation { continuation in
                        var didEmit = false
                        var didResume = false
                        disposable.setDisposable(
                            self.subscribe(
                                onSuccess: { value in
                                    didEmit = true
                                    didResume = true
                                    continuation.resume(returning: value)
                                },
                                onError: { error in
                                    didResume = true
                                    continuation.resume(throwing: error)
                                },
                                onCompleted: {
                                    guard !didEmit else { return }
                                    didResume = true
                                    continuation.resume(returning: nil)
                                },
                                onDisposed: {
                                    guard !didResume else { return }
                                    continuation.resume(throwing: CancellationError())
                                }
                            )
                        )
                    }
                },
                onCancel: { [disposable] in
                    disposable.dispose()
                }
            )
        }
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
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
            let disposable = SingleAssignmentDisposable()
            return try await withTaskCancellationHandler(
                operation: {
                    try await withCheckedThrowingContinuation { continuation in
                        var didResume = false
                        disposable.setDisposable(
                            self.subscribe(
                                onCompleted: {
                                    didResume = true
                                    continuation.resume()
                                },
                                onError: { error in
                                    didResume = true
                                    continuation.resume(throwing: error)
                                },
                                onDisposed: {
                                    guard !didResume else { return }
                                    continuation.resume(throwing: CancellationError())
                                }
                            )
                        )
                    }
                },
                onCancel: { [disposable] in
                    disposable.dispose()
                }
            )
        }
    }
}
#endif
