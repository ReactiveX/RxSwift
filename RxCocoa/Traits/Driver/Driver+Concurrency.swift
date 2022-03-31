//
//  Driver+Concurrency.swift
//  RxCocoa
//
//  Created by Jinwoo Kim on 3/30/22.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
// MARK: - Driver
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension Driver {
    /**
     Allows converting asynchronous block to `Driver` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - onErrorJustReturn: Element to return in case of error and after that complete the sequence.
        - block: An asynchronous block.
     - Returns: An Driver emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> Element, onErrorJustReturn: Element) -> Driver<Element> {
        return Single.from(priority: priority, detached: detached, block)
            .asDriver(onErrorJustReturn: onErrorJustReturn)
    }

    /**
     Allows converting asynchronous block to `Driver` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - onErrorDriveWith: Driver that continues to drive the sequence in case of error.
        - block: An asynchronous block.
     - Returns: An Driver emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> Element, onErrorDriveWith: Driver<Element>) -> Driver<Element> {
        return Single.from(priority: priority, detached: detached, block)
            .asDriver(onErrorDriveWith: onErrorDriveWith)
    }

    /**
     Allows converting asynchronous block to `Driver` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
        - block: An asynchronous block.
     - Returns: An Driver emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> Element, onErrorRecover: @escaping (Error) -> Driver<Element>) ->Driver<Element> {
        return Single.from(priority: priority, detached: detached, block)
            .asDriver(onErrorRecover: onErrorRecover)
    }
}
#endif
