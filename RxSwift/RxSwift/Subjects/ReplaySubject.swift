//
//  ReplaySubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ReplaySubject<Element> : Observable<Element>, SubjectType, ObserverType, Disposable {
    public typealias E = Element
    
    public typealias SubjectObserverType = ReplaySubject<Element>
    typealias DisposeKey = Bag<ObserverOf<Element>>.KeyType
    
    func unsubscribe(key: DisposeKey) {
        return abstractMethod()
    }
    
    public func on(event: Event<E>) {
        return abstractMethod()
    }
    
    public func asObserver() -> SubjectObserverType {
        return self
    }
    
    public func dispose() {
        
    }

    public static func create(bufferSize bufferSize: Int) -> ReplaySubject<Element> {
        if bufferSize == 1 {
            return ReplayOne()
        }
        else {
            return ReplayMany(bufferSize: bufferSize)
        }
    }
}

class ReplayBufferBase<Element> : ReplaySubject<Element> {
    var lock = NSRecursiveLock()
    
    // state
    var disposed = false
    var stoppedEvent = nil as Event<Element>?
    var observers = Bag<ObserverOf<Element>>()
    
    override init() {
        
    }
    
    func trim() {
        return abstractMethod()
    }
    
    func addValueToBuffer(value: Element) {
        return abstractMethod()
    }
    
    func replayBuffer(observer: ObserverOf<Element>) {
        return abstractMethod()
    }
    
    override func on(event: Event<Element>) {
        lock.performLocked {
            if self.disposed {
                return
            }
            
            if self.stoppedEvent != nil {
                return
            }
            
            switch event {
            case .Next(let value):
                addValueToBuffer(value)
                trim()
                self.observers.forEach { $0.on(event) }
            case .Error: fallthrough
            case .Completed:
                stoppedEvent = event
                trim()
                self.observers.forEach { $0.on(event) }
                observers.removeAll()
            }
            
        }
    }
    
    override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return lock.calculateLocked {
            if self.disposed {
                observers.forEach { $0.on(.Error(DisposedError)) }
                return NopDisposable.instance
            }
         
            let observerOf = observer.asObserver()
            
            replayBuffer(observerOf)
            if let stoppedEvent = self.stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            else {
                let key = self.observers.put(observerOf)
                return ReplaySubscription(subject: self, disposeKey: key)
            }
        }
    }
    
    override func unsubscribe(key: DisposeKey) {
        lock.performLocked {
            if self.disposed {
                return
            }
            
            _ = self.observers.removeKey(key)
        }
    }

    func lockedDispose() {
        disposed = true
        observers.removeAll()
    }
    
    override func dispose() {
        super.dispose()
        
        lock.performLocked {
            self.lockedDispose()
        }
    }
}

class ReplayOne<Element> : ReplayBufferBase<Element> {
    var value: Element?
    
    override init() {
        super.init()
    }
    
    override func trim() {
        
    }
    
    override func addValueToBuffer(value: Element) {
        self.value = value
    }
    
    override func replayBuffer(observer: ObserverOf<Element>) {
        if let value = self.value {
            observer.on(.Next(value))
        }
    }
    
    override func lockedDispose() {
        super.lockedDispose()
        
        value = nil
    }
}

class ReplayManyBase<Element> : ReplayBufferBase<Element> {
    var queue: Queue<Element>
    
    init(queueSize: Int) {
        queue = Queue(capacity: queueSize + 1)
    }
    
    override func addValueToBuffer(value: Element) {
        queue.enqueue(value)
    }
    
    override func replayBuffer(observer: ObserverOf<E>) {
        for item in queue {
            observer.on(.Next(item))
        }
    }
    
    override func lockedDispose() {
        super.lockedDispose()
        while queue.count > 0 {
            queue.dequeue()
        }
    }
}

class ReplayMany<Element> : ReplayManyBase<Element> {
    let bufferSize: Int
    
    init(bufferSize: Int) {
        self.bufferSize = bufferSize
        
        super.init(queueSize: bufferSize)
    }
    
    override func trim() {
        while queue.count > bufferSize {
            queue.dequeue()
        }
    }
}

class ReplayAll<Element> : ReplayManyBase<Element> {
    init() {
        super.init(queueSize: 0)
    }
    
    override func trim() {
        
    }
}

class ReplaySubscription<Element> : Disposable {
    typealias Subject = ReplaySubject<Element>
    typealias DisposeKey = ReplayBufferBase<Element>.DisposeKey
    
    var lock = SpinLock()
    
    // state
    var subject: Subject?
    var disposeKey: DisposeKey?
    
    init(subject: Subject, disposeKey: DisposeKey) {
        self.subject = subject
        self.disposeKey = disposeKey
    }
    
    func dispose() {
        let oldState = lock.calculateLocked { () -> (Subject?, DisposeKey?) in
            let state = (self.subject, self.disposeKey)
            self.subject = nil
            self.disposeKey = nil
            
            return state
        }
        
        if let subject = oldState.0, let disposeKey = oldState.1 {
            subject.unsubscribe(disposeKey)
        }
    }
}
