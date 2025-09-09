//
//  Observable+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.6) && canImport(_Concurrency)
import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension ObservableConvertibleType {

    typealias ElementObserver<Element> = (Element) -> Void

    /**
     Creates an `Observable` from the result of an asynchronous operation
     that emits elements via a provided observer closure.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter work: An `async` closure that takes an `ElementObserver` (a closure used to emit elements),
       and may call it multiple times to emit values.
       When the closure finishes, a `.completed` event is automatically emitted.
       If the closure throws, an `.error` event will be emitted instead.

     - returns: An `Observable` sequence of the element type emitted by the `work` closure.
    */
    @_disfavoredOverload
    static func create(
        detached: Bool = false,
        priority: TaskPriority? = nil,
        work: @Sendable @escaping (_ observer: ElementObserver<Element>) async throws -> Void
    ) -> Observable<Element> {
        .create { rawObserver in
            let operation: () async throws -> Void = {
                do {
                    let observer: ElementObserver<Element> = { element in
                        guard !Task.isCancelled else { return }
                        rawObserver.onNext(element)
                    }
                    try await work(observer)
                    rawObserver.onCompleted()
                } catch {
                    rawObserver.onError(error)
                }
            }

            let task = if detached {
                Task.detached(priority: priority, operation: operation)
            } else {
                Task(priority: priority, operation: operation)
            }

            return Disposables.create { task.cancel() }
        }
    }

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
            var isFinished = false
            let disposable = asObservable().subscribe(
                onNext: { value in continuation.yield(value) },
                onError: { error in
                    isFinished = true
                    continuation.finish(throwing: error)
                },
                onCompleted: {
                    isFinished = true
                    continuation.finish()
                },
                onDisposed: {
                    guard !isFinished else { return }
                    continuation.finish(throwing: CancellationError() )
                }
            )
            continuation.onTermination = { @Sendable termination in
                if case .cancelled = termination {
                    disposable.dispose()
                }
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
                } catch is CancellationError {
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
