//
//  PublishSubject.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Subscription<Element> : Disposable {
    typealias ObserverType = Observer<Element>
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

public class PublishSubject<Element> : Observable<Element>, SubjectType, Cancelable, ObserverType {
    public typealias E = Element
    public typealias SubjectObserverType = PublishSubject<Element>
    
    typealias DisposeKey = Bag<ObserverOf<Element>>.KeyType
    
    private var lock = NSRecursiveLock()
    // state
    var _disposed = false
    var observers = Bag<ObserverOf<Element>>()
    var stoppedEvent = nil as Event<Element>?
    
    public var disposed: Bool {
        get {
            return self.lock.calculateLocked {
                return _disposed
            }
        }
    }
    
    public override init() {
        super.init()
    }
    
    public func dispose() {
        self.lock.performLocked {
            _disposed = true
            self.observers = Bag()
        }
    }
    
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
    
    public override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return lock.calculateLocked {
            if let stoppedEvent = stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            
            if disposed {
                observer.on(.Error(DisposedError))
                return NopDisposable.instance
            }
            
            let key = observers.put(observer.asObserver())
            return Subscription(subject: self, key: key)
        }
    }

    func unsubscribe(key: DisposeKey) {
        self.lock.performLocked {
            _ = observers.removeKey(key)
        }
    }
    
    public func asObserver() -> PublishSubject<Element> {
        return self
    }
    
}