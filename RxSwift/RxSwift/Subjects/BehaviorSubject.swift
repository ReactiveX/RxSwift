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
    typealias ObserverBag = Bag<Observer<Element>>
    
    let lock = NSRecursiveLock()
    
    private var _value: RxResult<Element>
    private var observers: ObserverBag = Bag()
    private var stoppedEvent: Event<Element>?
 
    init(value: Element) {
        self._value = success(value)
        super.init()
    }
    
    // Returns value if value exists or throws exception if subject contains error
    public var value: Element {
        get {
            return lock.calculateLocked {
                _value.get()
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
    
    public var valueResult: RxResult<Element> {
        get {
            return lock.calculateLocked {
                _value
            }
        }
    }
    
    public override func on(event: Event<Element>) {
        let observers = lock.calculateLocked {
            if self.stoppedEvent != nil {
                return nil
            }
            
            switch event {
            case .Next: break
            case .Error:
                self.stoppedEvent = event
            case .Completed:
                self.stoppedEvent = event
            }
            
            return self.observers
        }
        
        dispatch(event, observers)
    }
    
    override public func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        
    }
}