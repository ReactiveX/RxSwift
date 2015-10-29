//
//  PublishSubject.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Subscription<Element> : Disposable {
    typealias KeyType = Bag<AnyObserver<Element>>.KeyType
    
    private var _lock = SpinLock()

    // state
    private var _subject: PublishSubject<Element>?
    private var _key: KeyType?
    
    init(subject: PublishSubject<Element>, key: KeyType) {
        _key = key
        _subject = subject
    }
    
    func dispose() {
        _lock.performLocked {
            guard let subject = _subject,
                let key = _key else {
                    return
            }
            
            _subject = nil
            _key = nil
            
            subject.unsubscribe(key)
        }
    }
}

/**
Represents an object that is both an observable sequence as well as an observer.

Each notification is broadcasted to all subscribed observers.
*/
public class PublishSubject<Element> : Observable<Element>, SubjectType, Cancelable, ObserverType {
    public typealias SubjectObserverType = PublishSubject<Element>
    
    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _disposed = false
    private var _observers = Bag<AnyObserver<Element>>()
    private var _stoppedEvent = nil as Event<Element>?
    
    /**
    Indicates whether the subject has been disposed.
    */
    public var disposed: Bool {
        get {
            return _lock.calculateLocked {
                return _disposed
            }
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
        _lock.performLocked {
            switch event {
            case .Next(_):
                if disposed || _stoppedEvent != nil {
                    return
                }
                
                _observers.forEach { $0.on(event) }
            case .Completed, .Error:
                if _stoppedEvent == nil {
                    _stoppedEvent = event
                    _observers.forEach { $0.on(event) }
                    _observers.removeAll()
                }
            }
        }
    }
    
    /**
    Subscribes an observer to the subject.
    
    - parameter observer: Observer to subscribe to the subject.
    - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    */
    public override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return _lock.calculateLocked {
            if let stoppedEvent = _stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            
            if disposed {
                observer.on(.Error(RxError.DisposedError))
                return NopDisposable.instance
            }
            
            let key = _observers.insert(observer.asObserver())
            return Subscription(subject: self, key: key)
        }
    }

    func unsubscribe(key: DisposeKey) {
        _lock.performLocked {
            _ = _observers.removeKey(key)
        }
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
        _lock.performLocked {
            _disposed = true
            _observers.removeAll()
            _stoppedEvent = nil
        }
    }
}