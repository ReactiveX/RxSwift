//
//  Variable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Variable is a wrapper for `BehaviorSubject`.

Unlike `BehaviorSubject` it can't terminate with error, and when variable is deallocated
 it will complete it's observable sequence (`asObservable`).
*/
@available(*, deprecated=2.0.0, message="Variable will remain in the 2.0.0 API, but just use `variable.asObservable()` because it won't be `ObservableType` (no way to warn about deprecated interface implementation). Just do, `variable.asObservable().map { _ in ...}` and ignore this warning.")
public class Variable<Element>
    :  ObservableType { // << -- this part and subscribe method will be deprecated

    public typealias E = Element
    
    private let _subject: BehaviorSubject<Element>
    
    private var _lock = SpinLock()
 
    // state
    private var _value: E
    
    /**
    Gets or sets current value of variable.
    
    If case new value is set, all observers are notified of that change.
    
    Even is case equal value is set, observers will still be notified.
    */
    public var value: E {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _value
        }
        set(newValue) {
            _lock.lock()
            _value = newValue
            _lock.unlock()

            _subject.on(.Next(newValue))
        }
    }
    
    /**
    Initializes variable with initial value.
    
    - parameter value: Initial variable value.
    */
    public init(_ value: Element) {
        _value = value
        _subject = BehaviorSubject(value: value)
    }
    
    /**
    Subscribes an observer to sequence of variable values.
    
    Immediately upon subscription current value is sent to the observer.
    
    - parameter observer: Observer to subscribe to variable values.
    - returns: Disposable object that can be used to unsubscribe the observer from the variable.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        return _subject.subscribe(observer)
    }
    
    /**
    - returns: Canonical interface for push style sequence
    */
    public func asObservable() -> Observable<E> {
        return _subject
    }

    deinit {
        _subject.on(.Completed)
    }
}