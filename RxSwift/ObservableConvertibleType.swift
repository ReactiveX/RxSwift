//
//  ObservableConvertibleType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Type that can be converted to observable sequence (`Observable<Element>`).
public protocol ObservableConvertibleType {
    /// Type of elements in sequence.
    associatedtype Element

    @available(*, deprecated, message: "Use `Element` instead.")
    typealias E = Element

    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    func asObservable() -> Observable<Element>
}
