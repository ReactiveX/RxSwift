//
//  GroupedObservable.swift
//  RxSwift
//
//  Created by Tomi Koskinen on 01/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an observable sequence of elements that have a common key.
public struct GroupedObservable<Key, Element, Completed, Error> : ObservableType {
    /// Gets the common key.
    public let key: Key

    private let source: ObservableSource<Element, Completed, Error>

    /// Initializes grouped observable sequence with key and source observable sequence.
    ///
    /// - parameter key: Grouped observable sequence key
    /// - parameter source: Observable sequence that represents sequence of elements for the key
    /// - returns: Grouped observable sequence of elements for the specific key
    public init(key: Key, source: ObservableSource<Element, Completed, Error>) {
        self.key = key
        self.source = source
    }

    /// Converts `self` to `Observable` sequence.
    public func asSource() -> ObservableSource<Element, Completed, Error> {
        return self.source
    }
}
