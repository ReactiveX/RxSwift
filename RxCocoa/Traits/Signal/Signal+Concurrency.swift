//
//  Signal+Concurrency.swift
//  RxCocoa
//
//  Created by Jinwoo Kim on 3/30/22.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
// MARK: - Signal
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension Signal {
    /**
     Allows converting asynchronous block to `Signal` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - onErrorJustReturn: Element to return in case of error and after that complete the sequence.
        - block: An asynchronous block.
     - Returns: An Signal emits value from `block` parameter.
     */
    static func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> Element, onErrorJustReturn: Element) -> Signal<Element> {
        return Single.from(priority: priority, detached: detached, block)
            .asSignal(onErrorJustReturn: onErrorJustReturn)
    }

    /**
     Allows converting asynchronous block to `Signal` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - onErrorSignalWith: Signal that continues to emit the sequence in case of error.
        - block: An asynchronous block.
     - Returns: An Signal emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    static func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> Element, onErrorSignalWith: Signal<Element>) -> Signal<Element> {
        return Single.from(priority: priority, detached: detached, block)
            .asSignal(onErrorSignalWith: onErrorSignalWith)
    }

    /**
     Allows converting asynchronous block to `Signal` trait.
     
     - Parameters:
        - priority: The priority of the task.
        - detached: Detach when creating the task.
        - onErrorRecover: Calculates signal that continues to emit the sequence in case of error.
        - block: An asynchronous block.
     - Returns: An Signal emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    static func from(priority: TaskPriority? = nil, detached: Bool = false, _ block: @escaping () async throws -> Element, onErrorRecover: @escaping (_ error: Swift.Error) -> Signal<Element>) -> Signal<Element> {
        return Single.from(priority: priority, detached: detached, block)
            .asSignal(onErrorRecover: onErrorRecover)
    }
}
#endif
