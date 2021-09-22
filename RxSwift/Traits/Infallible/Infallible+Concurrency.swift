//
//  Infallible+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5) && canImport(_Concurrency) && !os(Linux)
// MARK: - Infallible
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension InfallibleType {
    /// Allows iterating over the values of an Infallible
    /// asynchronously via Swift's concurrency features (`async/await`)
    ///
    /// A sample usage would look like so:
    ///
    /// ```swift
    /// for await value in observable.values {
    ///     // Handle emitted values
    /// }
    /// ```
    var values: AsyncStream<Element> {
        AsyncStream<Element> { continuation in
            _ = subscribe(
                onNext: { value in continuation.yield(value) },
                onCompleted: { continuation.finish() },
                onDisposed: { continuation.onTermination?(.cancelled) }
            )
        }
    }
}
#endif
