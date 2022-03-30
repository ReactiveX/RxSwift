//
//  Signal+Concurrency.swift
//  RxCocoa
//
//  Created by Jinwoo Kim on 3/30/22.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asSignal<Element>(_ fn: @escaping () async throws -> Element, onErrorJustReturn: Element) -> Signal<Element> {
    return asSingle(fn)
        .asSignal(onErrorJustReturn: onErrorJustReturn)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asSignal<Element>(_ fn: @escaping () async throws -> Element, onErrorSignalWith: Signal<Element>) -> Signal<Element> {
    return asSingle(fn)
        .asSignal(onErrorSignalWith: onErrorSignalWith)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asSignal<Element>(_ fn: @escaping () async throws -> Element, onErrorRecover: @escaping (_ error: Swift.Error) -> Signal<Element>) -> Signal<Element> {
    return asSingle(fn)
        .asSignal(onErrorRecover: onErrorRecover)
}
#endif
