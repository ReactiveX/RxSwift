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

    /**
     Creates an `Infallible` from the result of an asynchronous operation
     that emits elements via a provided observer closure.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter work: An `async` closure that takes an `ElementObserver` (a closure used to emit elements),
       and may call it multiple times to emit values.
       When the closure finishes, a `.completed` event is automatically emitted.

     - returns: An `Infallible` sequence of the element type emitted by the `work` closure.
    */
    @_disfavoredOverload
    static func create(
        detached: Bool = false,
        priority: TaskPriority? = nil,
        work: @Sendable @escaping (_ observer: ElementObserver<Element>) async -> Void
    ) -> Infallible<Element> {
        .create { rawObserver in
            let operation: () async -> Void = {
                let observer: ElementObserver<Element> = { element in
                    guard !Task.isCancelled else { return }
                    rawObserver(.next(element))
                }
                await work(observer)
                rawObserver(.completed)
            }

            let task = if detached {
                Task.detached(priority: priority, operation: operation)
            } else {
                Task(priority: priority, operation: operation)
            }

            return Disposables.create { task.cancel() }
        }
    }

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
