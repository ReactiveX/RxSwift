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
    typealias DisposeKey = Parent.ObserverBag.KeyType
    
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

public class BehaviorSubject<Element> : SubjectType<Element, Element> {
    typealias ObserverOf = Observer<Element>
    typealias ObserverBag = Bag<Observer<Element>>
    
    let lock = NSRecursiveLock()
    
    private var _value: Element
    private var observers: ObserverBag = Bag()
    private var stoppedEvent: Event<Element>?
 
    public init(value: Element) {
        self._value = value
        super.init()
    }
    
    // Returns value if value exists or throws exception if subject contains error
    public var value: Element {
        get {
            return lock.calculateLocked {
                if let error = stoppedEvent?.error {
                    // intentionally throw exception
                    return failure(error).get()
                }
                else {
                    return _value
                }
            }
        }
    }

    public var valueResult: RxResult<Element> {
        get {
            return lock.calculateLocked {
                if let error = stoppedEvent?.error {
                    // intentionally throw exception
                    return failure(error)
                }
                else {
                    return success(_value)
                }
            }
        }
    }
    
    
    public var hasObservers: Bool {
        get {
            return lock.calculateLocked {
                observers.count > 0
            }
        }
    }
    
    public override func on(event: Event<Element>) {
        let observers = lock.calculateLocked { () -> [Observer<Element>]? in
            if self.stoppedEvent != nil {
                return nil
            }
            
            switch event {
            case .Next(let boxedValue):
                self._value = boxedValue.value
            case .Error:
                self.stoppedEvent = event
            case .Completed:
                self.stoppedEvent = event
            }
            
            return self.observers.all
        }
        
        dispatch(event, observers)
    }
    
    override public func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        let disposeKey = lock.calculateLocked { () -> ObserverBag.KeyType? in
            if let stoppedEvent = stoppedEvent {
                send(observer, stoppedEvent)
                return nil
            }
            
            let key = observers.put(ObserverOf.normalize(observer))
            sendNext(observer, _value)
            return key
        }
        
        if let disposeKey = disposeKey {
            return BehaviorSubjectSubscription(parent: self, disposeKey: disposeKey)
        }
        else {
            return NopDisposable.instance
        }
    }
}