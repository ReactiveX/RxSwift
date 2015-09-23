//
//  Variable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Variable is a wrapper for `BehaviorSubject`.

Unlike `BehaviorSubject` it can't terminate with error.
*/
public class Variable<Element> : ObservableType {
    public typealias E = Element
    
    let subject: BehaviorSubject<Element>
    
    private var lock = SpinLock()
 
    // state
    private var _value: E
    
    /**
    Gets or sets current value of variable.
    
    If case new value is set, all observers are notified of that change.
    
    Even is case equal value is set, observers will still be notified.
    */
    public var value: E {
        get {
            return lock.calculateLocked {
                return _value
            }
        }
        set(newValue) {
            lock.performLocked {
                _value = newValue
            }
            self.subject.on(.Next(newValue))
        }
    }
    
    /**
    Initializes variable with initial value.
    
    - parameter value: Initial variable value.
    */
    public init(_ value: Element) {
        self._value = value
        self.subject = BehaviorSubject(value: value)
    }
    
    /**
    Subscribes an observer to sequence of variable values.
    
    Immediately upon subscription current value is sent to the observer.
    
    - parameter observer: Observer to subscribe to variable values.
    - returns: Disposable object that can be used to unsubscribe the observer from the variable.
    */
    public func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.subject.subscribe(observer)
    }
    
    /**
    - returns: Canonical interface for push style sequence
    */
    public func asObservable() -> Observable<E> {
        return self.subject
    }
}