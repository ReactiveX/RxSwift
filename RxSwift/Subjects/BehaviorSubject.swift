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

public class BehaviorSubject<Element> : Observable<Element>, SubjectType, ObserverType {
    public typealias E = Element
    public typealias SubjectObserverType = BehaviorSubject<Element>
    
    let lock = NSRecursiveLock()
    
    // state
    private var _value: Element
    private var observers = Bag<ObserverOf<Element>>()
    private var stoppedEvent: Event<Element>?
 
    public init(value: Element) {
        self._value = value
    }
    
    // Returns value if value exists or throws exception if subject contains error
    public func value() throws -> Element {
        return try lock.calculateLockedOrFail {
            if let error = stoppedEvent?.error {
                // intentionally throw exception
                throw error
            }
            else {
                return _value
            }
        }
    }

    public func on(event: Event<E>) {
        lock.performLocked {
            if self.stoppedEvent != nil {
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
    
    public override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return lock.calculateLocked {
            if let stoppedEvent = stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            
            let key = observers.put(observer.asObserver())
            observer.on(.Next(_value))
        
            return BehaviorSubjectSubscription(parent: self, disposeKey: key)
        }
    }

    public func asObserver() -> BehaviorSubject<Element> {
        return self
    }
}