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
public class Variable<Element> {

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
    - returns: Canonical interface for push style sequence
    */
    public func asObservable() -> Observable<E> {
        return _subject
    }

    deinit {
        _subject.on(.Completed)
    }
}