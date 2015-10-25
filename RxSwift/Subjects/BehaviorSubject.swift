//
//  BehaviorSubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

private class BehaviorSubjectSubscription<Element> : Disposable {
    typealias Parent = BehaviorSubject<Element>
    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType
    
    private let _parent: Parent
    private var _disposeKey: DisposeKey?
    
    init(parent: BehaviorSubject<Element>, disposeKey: DisposeKey) {
        _parent = parent
        _disposeKey = disposeKey
    }
    
    func dispose() {
        _parent._lock.performLocked {
            if let disposeKey = _disposeKey {
                _parent._observers.removeKey(disposeKey)
                _disposeKey = nil
            }
        }
    }
}

/**
Represents a value that changes over time.

Observers can subscribe to the subject to receive the last (or initial) value and all subsequent notifications.
*/
public final class BehaviorSubject<Element> : Observable<Element>, SubjectType, ObserverType, Disposable {
    public typealias SubjectObserverType = BehaviorSubject<Element>
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _disposed = false
    private var _value: Element
    private var _observers = Bag<AnyObserver<Element>>()
    private var _stoppedEvent: Event<Element>?

    /**
    Indicates whether the subject has been disposed.
    */
    public var disposed: Bool {
        return _lock.calculateLocked {
            return _disposed
        }
    }
 
    /**
    Initializes a new instance of the subject that caches its last value and starts with the specified value.
    
    - parameter value: Initial value sent to observers when no other value has been received by the subject yet.
    */
    public init(value: Element) {
        _value = value
    }
    
    /**
    Gets the current value or throws an error.
    
    - returns: Latest value.
    */
    public func value() throws -> Element {
        return try _lock.calculateLockedOrFail {
            if _disposed {
                throw RxError.DisposedError
            }
            
            if let error = _stoppedEvent?.error {
                // intentionally throw exception
                throw error
            }
            else {
                return _value
            }
        }
    }
    
    /**
    Notifies all subscribed observers about next event.
    
    - parameter event: Event to send to the observers.
    */
    public func on(event: Event<E>) {
        _lock.performLocked {
            if _stoppedEvent != nil || _disposed {
                return
            }
            
            switch event {
            case .Next(let value):
                _value = value
            case .Error, .Completed:
                _stoppedEvent = event
            }
            
            _observers.on(event)
        }
    }
    
    /**
    Subscribes an observer to the subject.
    
    - parameter observer: Observer to subscribe to the subject.
    - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    */
    public override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return _lock.calculateLocked {
            if _disposed {
                observer.on(.Error(RxError.DisposedError))
                return NopDisposable.instance
            }
            
            if let stoppedEvent = _stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            
            let key = _observers.insert(observer.asObserver())
            observer.on(.Next(_value))
        
            return BehaviorSubjectSubscription(parent: self, disposeKey: key)
        }
    }

    /**
    Returns observer interface for subject.
    */
    public func asObserver() -> BehaviorSubject<Element> {
        return self
    }

    /**
    Unsubscribe all observers and release resources.
    */
    public func dispose() {
        _lock.performLocked {
            _disposed = true
            _observers.removeAll()
            _stoppedEvent = nil
        }
    }
}