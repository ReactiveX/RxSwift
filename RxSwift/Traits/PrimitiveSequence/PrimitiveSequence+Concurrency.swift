//
//  PrimitiveSequence+Concurrency.swift
//  RxSwift
//
//  Created by Shai Mishali on 22/09/2021.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
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
                        disposable.setDisposable(
                            self.subscribe(
                                onSuccess: { continuation.resume(returning: $0) },
                                onFailure: { continuation.resume(throwing: $0) }
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
    
    /**
     Allows converting asynchronous block to `Single` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - block: An asynchronous block.
     - Returns: An Single emits value from `block` parameter.
     */
    static func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> Element) -> Single<Element> {
        return .create { observer in
            let operation: @Sendable () async -> Void = {
                do {
                    let element = try await block()
                    observer(.success(element))
                } catch {
                    observer(.failure(error))
                }
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
                        disposable.setDisposable(
                            self.subscribe(
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
                        )
                    }
                },
                onCancel: { [disposable] in
                    disposable.dispose()
                }
            )
        }
    }
    
    /**
     Allows converting asynchronous block to `Maybe` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - block: An asynchronous block.
     - Returns: An Maybe emits value from `block` parameter.
     */
    static func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: (() async throws -> Element)?) -> Maybe<Element> {
        return .create { observer in
            let operation: @Sendable () async -> Void = {
                do {
                    guard let fn = block else {
                        observer(.completed)
                        return
                    }
                    
                    let element = try await fn()
                    observer(.success(element))
                } catch {
                    observer(.error(error))
                }
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
                        disposable.setDisposable(
                            self.subscribe(
                                onCompleted: { continuation.resume() },
                                onError: { error in continuation.resume(throwing: error) }
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
    
    /**
     Allows converting asynchronous block to `Completable` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - block: An asynchronous block.
     - Returns: An Completable emits value from `block` parameter.
     */
    static func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> ()) -> Completable {
        return .create { observer in
            let operation: @Sendable () async -> Void = {
                do {
                    try await block()
                    observer(.completed)
                } catch {
                    observer(.error(error))
                }
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
