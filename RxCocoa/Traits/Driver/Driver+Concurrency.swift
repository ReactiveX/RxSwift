//
//  Driver+Concurrency.swift
//  RxCocoa
//
//  Created by Jinwoo Kim on 3/30/22.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asDriver<Element>(_ fn: @escaping () async throws -> Element, onErrorJustReturn: Element) -> Driver<Element> {
    return asSingle(fn)
        .asDriver(onErrorJustReturn: onErrorJustReturn)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asDriver<Element>(_ fn: @escaping () async throws -> Element, onErrorDriveWith: Driver<Element>) -> Driver<Element> {
    return asSingle(fn)
        .asDriver(onErrorDriveWith: onErrorDriveWith)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func asDriver<Element>(_ fn: @escaping () async throws -> Element, onErrorRecover: @escaping (Error) -> Driver<Element>) ->Driver<Element> {
    return asSingle(fn)
        .asDriver(onErrorRecover: onErrorRecover)
}
#endif
