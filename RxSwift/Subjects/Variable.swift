//
//  Variable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Variables can be useful when interacting with imperative 
public class Variable<Element> : ObservableType {
    public typealias E = Element
    
    let subject: BehaviorSubject<Element>
    
    public private(set) var value: E
    
    private var lock = SpinLock()
    
    public init(_ value: Element) {
        self.value = value
        self.subject = BehaviorSubject(value: value)
        self.subject.on(.Next(value))
    }
    
    /// Subscribes `observer` to receive events from this observable
    public func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.subject.subscribe(observer)
    }
    
    public func asObservable() -> Observable<E> {
        return self.subject
    }
    
    public func sendNext(value: Element) {
        lock.performLocked {
            self.value = value
        }
        self.subject.on(.Next(value))
    }
    
    deinit {
        self.subject.on(.Completed)
    }
}