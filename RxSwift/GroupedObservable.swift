//
//  GroupedObservable.swift
//  RxSwift
//
//  Created by Tomi Koskinen on 01/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an observable sequence of elements that share a common key.
/// `GroupedObservable` is typically created by the `groupBy` operator.
/// Each `GroupedObservable` instance represents a collection of elements
/// that are grouped by a specific key.
///
/// Example usage:
/// ```
/// let observable = Observable.of("Apple", "Banana", "Apricot", "Blueberry", "Avocado")
///
/// let grouped = observable.groupBy { fruit in
///     fruit.first! // Grouping by the first letter of each fruit
/// }
///
/// _ = grouped.subscribe { group in
///     print("Group: \(group.key)")
///     _ = group.subscribe { event in
///         print(event)
///     }
/// }
/// ```
/// This will print:
/// ```
/// Group: A
/// next(Apple)
/// next(Apricot)
/// next(Avocado)
/// Group: B
/// next(Banana)
/// next(Blueberry)
/// ```
public struct GroupedObservable<Key, Element> : ObservableType {
    /// The key associated with this grouped observable sequence.
    /// All elements emitted by this observable share this common key.
    public let key: Key

    private let source: Observable<Element>

    /// Initializes a grouped observable sequence with a key and a source observable sequence.
    ///
    /// - Parameters:
    ///   - key: The key associated with this grouped observable sequence.
    ///   - source: The observable sequence of elements for the specified key.
    ///
    /// Example usage:
    /// ```
    /// let sourceObservable = Observable.of("Apple", "Apricot", "Avocado")
    /// let groupedObservable = GroupedObservable(key: "A", source: sourceObservable)
    ///
    /// _ = groupedObservable.subscribe { event in
    ///     print(event)
    /// }
    /// ```
    /// This will print:
    /// ```
    /// next(Apple)
    /// next(Apricot)
    /// next(Avocado)
    /// ```
    public init(key: Key, source: Observable<Element>) {
        self.key = key
        self.source = source
    }

    /// Subscribes an observer to receive events emitted by the source observable sequence.
    ///
    /// - Parameter observer: The observer that will receive the events of the source observable.
    /// - Returns: A `Disposable` representing the subscription, which can be used to cancel the subscription.
    ///
    /// Example usage:
    /// ```
    /// let fruitsObservable = Observable.of("Apple", "Banana", "Apricot", "Blueberry", "Avocado")
    /// let grouped = fruitsObservable.groupBy { $0.first! } // Group by first letter
    ///
    /// _ = grouped.subscribe { group in
    ///     if group.key == "A" {
    ///         _ = group.subscribe { event in
    ///             print(event)
    ///         }
    ///     }
    /// }
    /// ```
    /// This will print:
    /// ```
    /// next(Apple)
    /// next(Apricot)
    /// next(Avocado)
    /// ```
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self.source.subscribe(observer)
    }

    /// Converts this `GroupedObservable` into a regular `Observable` sequence.
    /// This allows you to work with the sequence without directly interacting with the key.
    ///
    /// - Returns: The underlying `Observable` sequence of elements for the specified key.
    ///
    /// Example usage:
    /// ```
    /// let fruitsObservable = Observable.of("Apple", "Banana", "Apricot", "Blueberry", "Avocado")
    /// let grouped = fruitsObservable.groupBy { $0.first! } // Group by first letter
    ///
    /// _ = grouped.subscribe { group in
    ///     if group.key == "A" {
    ///         let regularObservable = group.asObservable()
    ///         _ = regularObservable.subscribe { event in
    ///             print(event)
    ///         }
    ///     }
    /// }
    /// ```
    /// This will print:
    /// ```
    /// next(Apple)
    /// next(Apricot)
    /// next(Avocado)
    /// ```
    public func asObservable() -> Observable<Element> {
        self.source
    }
}

