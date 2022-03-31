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
     
     - parameter block: An asynchronous block
     - parameter parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
     - returns: An Driver emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func from(_ block: @escaping () async throws -> Element, onErrorJustReturn: Element) -> Driver<Element> {
        return Single.from(block)
            .asDriver(onErrorJustReturn: onErrorJustReturn)
    }

    /**
     Allows converting asynchronous block to `Driver` trait.
     
     - parameter block: An asynchronous block
     - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
     - returns: An Driver emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func from(_ block: @escaping () async throws -> Element, onErrorDriveWith: Driver<Element>) -> Driver<Element> {
        return Single.from(block)
            .asDriver(onErrorDriveWith: onErrorDriveWith)
    }

    /**
     Allows converting asynchronous block to `Driver` trait.
     
     - parameter block: An asynchronous block
     - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
     - returns: An Driver emits value from `block` parameter.
     */
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func from(_ block: @escaping () async throws -> Element, onErrorRecover: @escaping (Error) -> Driver<Element>) ->Driver<Element> {
        return Single.from(block)
            .asDriver(onErrorRecover: onErrorRecover)
    }
}
#endif
