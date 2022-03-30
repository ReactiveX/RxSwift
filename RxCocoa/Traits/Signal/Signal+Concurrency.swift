//
//  Signal+Concurrency.swift
//  RxCocoa
//
//  Created by Jinwoo Kim on 3/30/22.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
/**
 Allows converting asynchronous block to `Signal` trait.
 
 - parameter block: An asynchronous block
 - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
 - returns: An Signal emits value from `block` parameter.
 */
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asSignal<Element>(_ block: @escaping () async throws -> Element, onErrorJustReturn: Element) -> Signal<Element> {
    return asSingle(block)
        .asSignal(onErrorJustReturn: onErrorJustReturn)
}

/**
 Allows converting asynchronous block to `Signal` trait.
 
 - parameter block: An asynchronous block
 - parameter onErrorSignalWith: Signal that continues to emit the sequence in case of error.
 - returns: An Signal emits value from `block` parameter.
 */
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asSignal<Element>(_ block: @escaping () async throws -> Element, onErrorSignalWith: Signal<Element>) -> Signal<Element> {
    return asSingle(block)
        .asSignal(onErrorSignalWith: onErrorSignalWith)
}

/**
 Allows converting asynchronous block to `Signal` trait.
 
 - parameter block: An asynchronous block
 - parameter onErrorRecover: Calculates signal that continues to emit the sequence in case of error.
 - returns: An Signal emits value from `block` parameter.
 */
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asSignal<Element>(_ block: @escaping () async throws -> Element, onErrorRecover: @escaping (_ error: Swift.Error) -> Signal<Element>) -> Signal<Element> {
    return asSingle(block)
        .asSignal(onErrorRecover: onErrorRecover)
}
#endif
