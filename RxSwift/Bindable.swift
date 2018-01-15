//
//  Bindable.swift
//  Rx
//
//  Created by Mostafa Amer on 15.01.18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

/// Represents a type that can be used with `func bind(to:) -> Disposable`.
public protocol Bindable {
    /// The type of elements in sequence that observer can observe.
    associatedtype T
    /// Handle a given sequence event.
    ///
    /// - parameter event: Event that occurred.
    func handle(_ event: Event<T>)
}

