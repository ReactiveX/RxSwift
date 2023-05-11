//
//  Infallible+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.6) && canImport(_Concurrency) && !os(Linux)
// MARK: - Infallible
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
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
            let disposable = subscribe(
                onNext: { value in continuation.yield(value) },
                onCompleted: { continuation.finish() }
            )
            continuation.onTermination = { @Sendable termination in
                if termination == .cancelled {
                    disposable.dispose()
                }
            }
        }
    }
}
#endif
