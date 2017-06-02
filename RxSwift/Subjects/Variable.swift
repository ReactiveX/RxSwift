//
//  Variable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Variable is a wrapper for `BehaviorSubject`.
///
/// Unlike `BehaviorSubject` it can't terminate with error, and when variable is deallocated
/// it will complete its observable sequence (`asObservable`).
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
            _lock.lock(); defer { _lock.unlock() }
            return _value
        }
        set(newValue) {
            #if DEBUG
                _synchronizationTracker.register(synchronizationErrorMessage: .variable)
                defer { _synchronizationTracker.unregister() }
            #endif
            _lock.lock()
            _value = newValue
            _lock.unlock()

            _subject.on(.next(newValue))
        }
    }
    
    /// Initializes variable with initial value.
    ///
    /// - parameter value: Initial variable value.
    public init(_ value: Element) {
        _value = value
        _subject = BehaviorSubject(value: value)
    }

    /// Observable that synchronously sends current element and then changed elements.
    ///
    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<E> {
        return _subject
    }

    /// Observable that only sends changed elements, ignoring current element.
    public var changed: Observable<E> {
        return asObservable().skip(1)
    }

    deinit {
        _subject.on(.completed)
    }
}
