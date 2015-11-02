//
//  PublishSubject.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents an object that is both an observable sequence as well as an observer.

Each notification is broadcasted to all subscribed observers.
*/
public class PublishSubject<Element>
    : Observable<Element>
    , SubjectType
    , Cancelable
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType
    , SynchronizedSubscribeType
    , SynchronizedUnsubscribeType
    , SynchronizedDisposeType {
    public typealias SubjectObserverType = PublishSubject<Element>
    
    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType
    
    let _lock = NSRecursiveLock()
    
    // state
    private var _disposed = false
    private var _observers = Bag<AnyObserver<Element>>()
    private var _stoppedEvent = nil as Event<Element>?
    
    /**
    Indicates whether the subject has been disposed.
    */
    public var disposed: Bool {
        get {
            return _disposed
        }
    }
    
    /**
    Creates a subject.
    */
    public override init() {
        super.init()
    }
    
    /**
    Notifies all subscribed observers about next event.
    
    - parameter event: Event to send to the observers.
    */
    public func on(event: Event<Element>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<E>) {
        switch event {
        case .Next(_):
            if _disposed || _stoppedEvent != nil {
                return
            }
            
            _observers.on(event)
        case .Completed, .Error:
            if _stoppedEvent == nil {
                _stoppedEvent = event
                _observers.on(event)
                _observers.removeAll()
            }
        }
    }
    
    /**
    Subscribes an observer to the subject.
    
    - parameter observer: Observer to subscribe to the subject.
    - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    */
    public override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return synchronizedSubscribe(observer)
    }

    func _synchronized_subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        if let stoppedEvent = _stoppedEvent {
            observer.on(stoppedEvent)
            return NopDisposable.instance
        }
        
        if _disposed {
            observer.on(.Error(RxError.DisposedError))
            return NopDisposable.instance
        }
        
        let key = _observers.insert(observer.asObserver())
        return SubscriptionDisposable(owner: self, key: key)
    }


    func _synchronized_unsubscribe(disposeKey: DisposeKey) {
        _ = _observers.removeKey(disposeKey)
    }
    
    /**
    Returns observer interface for subject.
    */
    public func asObserver() -> PublishSubject<Element> {
        return self
    }
    
    /**
    Unsubscribe all observers and release resources.
    */
    public func dispose() {
        synchronizedDispose()
    }

    func _synchronized_dispose() {
        _disposed = true
        _observers.removeAll()
        _stoppedEvent = nil
    }
}