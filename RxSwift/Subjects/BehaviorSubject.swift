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
    typealias DisposeKey = Bag<ObserverOf<Element>>.KeyType
    
    let parent: Parent
    var disposeKey: DisposeKey?
    
    init(parent: BehaviorSubject<Element>, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func dispose() {
        self.parent.lock.performLocked {
            if let disposeKey = disposeKey {
                self.parent.observers.removeKey(disposeKey)
                self.disposeKey = nil
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
    
    let lock = NSRecursiveLock()
    
    // state
    private var _disposed = false
    private var _value: Element
    private var observers = Bag<ObserverOf<Element>>()
    private var stoppedEvent: Event<Element>?

    /**
    Indicates whether the subject has been disposed.
    */
    public var disposed: Bool {
        return lock.calculateLocked {
            return _disposed
        }
    }
 
    /**
    Initializes a new instance of the subject that caches its last value and starts with the specified value.
    
    - parameter value: Initial value sent to observers when no other value has been received by the subject yet.
    */
    public init(value: Element) {
        self._value = value
    }
    
    /**
    Gets the current value or throws an error.
    
    - returns: Latest value.
    */
    public func value() throws -> Element {
        return try lock.calculateLockedOrFail {
            if _disposed {
                throw RxError.DisposedError
            }
            
            if let error = stoppedEvent?.error {
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
        lock.performLocked {
            if self.stoppedEvent != nil || _disposed {
                return
            }
            
            switch event {
            case .Next(let value):
                self._value = value
            case .Error:
                self.stoppedEvent = event
            case .Completed:
                self.stoppedEvent = event
            }
            
            self.observers.forEach { $0.on(event) }
        }
    }
    
    /**
    Subscribes an observer to the subject.
    
    - parameter observer: Observer to subscribe to the subject.
    - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    */
    public override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return lock.calculateLocked {
            if _disposed {
                observer.on(.Error(RxError.DisposedError))
                return NopDisposable.instance
            }
            
            if let stoppedEvent = stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            
            let key = observers.insert(observer.asObserver())
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
        lock.performLocked {
            _disposed = true
            observers.removeAll()
            stoppedEvent = nil
        }
    }
}