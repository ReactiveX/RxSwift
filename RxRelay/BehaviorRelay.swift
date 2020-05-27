//
//  BehaviorRelay.swift
//  RxRelay
//
//  Created by Krunoslav Zaher on 10/7/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// BehaviorRelay is a wrapper for `BehaviorSubject`.
///
/// Unlike `BehaviorSubject` it can't terminate with error or completed.
@propertyWrapper
public final class BehaviorRelay<Element>: ObservableType {
    private let _subject: BehaviorSubject<Element>

    /// Accepts `event` and emits it to subscribers
    public func accept(_ event: Element) {
        self._subject.onNext(event)
    }

    /// Current value of behavior subject
    public var value: Element {
        // this try! is ok because subject can't error out or be disposed
        return try! self._subject.value()
    }

    /// Initializes behavior relay with initial value.
    public init(value: Element) {
        self._subject = BehaviorSubject(value: value)
    }

    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        return self._subject.subscribe(observer)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        return self._subject.asObservable()
    }

  /// Setting a new value is equivalent to `accept(newValue)`
    public var wrappedValue: Element {
        get { value }
        set { accept(newValue) }
    }

    /// The property that can be accessed with the `$` syntax and allows access to the `BehaviorRelay`
    public var projectedValue: BehaviorRelay<Element> {
        return self
    }

    /// Initializes behavior relay with initial value.
    /// Used when initializing with `propertyWrapper`
    ///    Usage:
    ///
    ///     @BehaviorRelay var counter: Int = 0
    /// - Parameter wrappedValue: Initial value for BehaviorRelay
    public convenience init(wrappedValue: Element) {
        self.init(value: wrappedValue)
    }
}
