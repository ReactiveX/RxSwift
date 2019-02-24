//
//  Deprecated.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/5/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//


/// Variable is a wrapper for `BehaviorSubject`.
///
/// Unlike `BehaviorSubject` it can't terminate with error, and when variable is deallocated
/// it will complete its observable sequence (`asObservable`).
///
/// **This concept will be deprecated from RxSwift but offical migration path hasn't been decided yet.**
/// https://github.com/ReactiveX/RxSwift/issues/1501
///
/// Current recommended replacement for this API is `RxCocoa.BehaviorRelay` because:
/// * `Variable` isn't a standard cross platform concept, hence it's out of place in RxSwift target.
/// * It doesn't have a counterpart for handling events (`PublishRelay`). It models state only.
/// * It doesn't have a consistent naming with *Relay or other Rx concepts.
/// * It has an inconsistent memory management model compared to other parts of RxSwift (completes on `deinit`).
///
/// Once plans are finalized, official availability attribute will be added in one of upcoming versions.
public final class Variable<Element> {

    public typealias E = Element

    private let _subject: BehaviorSubject<Element>

    private var _lock = SpinLock()

    // state
    private var _value: E

    #if DEBUG
    fileprivate let _synchronizationTracker = SynchronizationTracker()
    #endif

    /// Gets or sets current value of variable.
    ///
    /// Whenever a new value is set, all the observers are notified of the change.
    ///
    /// Even if the newly set value is same as the old value, observers are still notified for change.
    public var value: E {
        get {
            self._lock.lock(); defer { self._lock.unlock() }
            return self._value
        }
        set(newValue) {
            #if DEBUG
                self._synchronizationTracker.register(synchronizationErrorMessage: .variable)
                defer { self._synchronizationTracker.unregister() }
            #endif
            self._lock.lock()
            self._value = newValue
            self._lock.unlock()

            self._subject.on(.next(newValue))
        }
    }

    /// Initializes variable with initial value.
    ///
    /// - parameter value: Initial variable value.
    public init(_ value: Element) {
        #if DEBUG
            DeprecationWarner.warnIfNeeded(.variable)
        #endif

        self._value = value
        self._subject = BehaviorSubject(value: value)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<E> {
        return self._subject
    }

    deinit {
        self._subject.on(.completed)
    }
}
