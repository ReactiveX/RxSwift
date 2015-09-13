//
//  PublishSubject.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Subscription<Element> : Disposable {
    typealias KeyType = Bag<ObserverOf<Element>>.KeyType
    
    private var lock = SpinLock()

    // state
    private var subject: PublishSubject<Element>?
    private var key: KeyType?
    
    init(subject: PublishSubject<Element>, key: KeyType) {
        self.key = key
        self.subject = subject
    }
    
    func dispose() {
        lock.performLocked {
            guard let subject = subject else {
                return
            }
            
            guard let key = key else {
                return
            }
            
            self.subject = nil
            self.key = nil
            
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
    
    typealias DisposeKey = Bag<ObserverOf<Element>>.KeyType
    
    private let lock = NSRecursiveLock()
    
    // state
    var _disposed = false
    var observers = Bag<ObserverOf<Element>>()
    var stoppedEvent = nil as Event<Element>?
    
    /**
    Indicates whether the subject has been disposed.
    */
    public var disposed: Bool {
        get {
            return self.lock.calculateLocked {
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
        lock.performLocked {
            switch event {
            case .Next(_):
                if disposed || stoppedEvent != nil {
                    return
                }
                
                observers.forEach { $0.on(event) }
            case .Completed: fallthrough
            case .Error:
                if stoppedEvent == nil {
                    self.stoppedEvent = event
                    observers.forEach { $0.on(event) }
                    self.observers.removeAll()
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
        return lock.calculateLocked {
            if let stoppedEvent = stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            
            if disposed {
                observer.on(.Error(RxError.DisposedError))
                return NopDisposable.instance
            }
            
            let key = observers.insert(observer.asObserver())
            return Subscription(subject: self, key: key)
        }
    }

    func unsubscribe(key: DisposeKey) {
        self.lock.performLocked {
            _ = observers.removeKey(key)
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
        self.lock.performLocked {
            _disposed = true
            self.observers.removeAll()
            self.stoppedEvent = nil
        }
    }
}