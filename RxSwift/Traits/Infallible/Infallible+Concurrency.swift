//
//  Infallible+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
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
                onCompleted: { continuation.finish() },
                onDisposed: { continuation.onTermination?(.cancelled) }
            )
            
            continuation.onTermination = { @Sendable _ in
                disposable.dispose()
            }
        }
    }
    
    /**
     Allows converting asynchronous block to `Infailable` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - block: An asynchronous block.
     - Returns: An Infailable emits value from `block` parameter.
     */
    static func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async -> Element) -> Infallible<Element> {
        return .create { observer in
            let operation: @Sendable () async -> Void = {
                let element = await block()
                observer(.next(element))
                observer(.completed)
            }
            let task: Task<Void, Swift.Error>
            
            if detached {
                task = Task.detached(priority: priority, operation: operation)
            } else {
                task = Task(priority: priority, operation: operation)
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
#endif
