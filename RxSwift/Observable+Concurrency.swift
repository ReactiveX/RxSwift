//
//  Observable+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5.2) && canImport(_Concurrency)
import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension ObservableConvertibleType {
    /// Allows iterating over the values of an Observable
    /// asynchronously via Swift's concurrency features (`async/await`)
    ///
    /// A sample usage would look like so:
    ///
    /// ```swift
    /// do {
    ///     for try await value in observable.values {
    ///         // Handle emitted values
    ///     }
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    var values: AsyncThrowingStream<Element, Error> {
        AsyncThrowingStream<Element, Error> { continuation in
            let disposable = asObservable().subscribe(
                onNext: { value in continuation.yield(value) },
                onError: { error in continuation.finish(throwing: error) },
                onCompleted: { continuation.finish() },
                onDisposed: { continuation.onTermination?(.cancelled) }
            )

            continuation.onTermination = { @Sendable _ in
                disposable.dispose()
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension AsyncSequence {
    /// Convert an `AsyncSequence` to an `Observable` emitting
    /// values of the asynchronous sequence's type
    ///
    /// - returns: An `Observable` of the async sequence's type
    func asObservable() -> Observable<Element> {
        Observable.create { observer in
            let task = Task {
                do {
                    for try await value in self {
                        observer.onNext(value)
                    }

                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create { task.cancel() }
        }
    }
}
#endif
