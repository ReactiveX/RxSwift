//
//  SharedSequence+Concurrency.swift
//  RxCocoa
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
import Foundation

// MARK: - Shared Sequence
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SharedSequence {
    /// Allows iterating over the values of this Shared Sequence
    /// asynchronously via Swift's concurrency features (`async/await`)
    ///
    /// A sample usage would look like so:
    ///
    /// ```swift
    /// for await value in driver.values {
    ///     // Handle emitted values
    /// }
    /// ```
    @MainActor var values: AsyncStream<Element> {
        AsyncStream { continuation in
            // It is safe to ignore the `onError` closure here since
            // Shared Sequences (`Driver` and `Signal`) cannot fail
            let disposable = self.asObservable()
                .subscribe(
                    onNext: { value in continuation.yield(value) },
                    onCompleted: { continuation.finish() },
                    onDisposed: { continuation.onTermination?(.cancelled) }
                )

            continuation.onTermination = { @Sendable _ in
                disposable.dispose()
            }
        }
    }
}
#endif
