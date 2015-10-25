//
//  ReplaySubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents an object that is both an observable sequence as well as an observer.

Each notification is broadcasted to all subscribed and future observers, subject to buffer trimming policies.
*/
public class ReplaySubject<Element> : Observable<Element>, SubjectType, ObserverType, Disposable {
    public typealias SubjectObserverType = ReplaySubject<Element>
    
    typealias DisposeKey = Bag<AnyObserver<Element>>.KeyType
    
    func unsubscribe(key: DisposeKey) {
        abstractMethod()
    }
    
    /**
    Notifies all subscribed observers about next event.
    
    - parameter event: Event to send to the observers.
    */
    public func on(event: Event<E>) {
        abstractMethod()
    }
    
    /**
    Returns observer interface for subject.
    */
    public func asObserver() -> SubjectObserverType {
        return self
    }
    
    /**
    Unsubscribe all observers and release resources.
    */
    public func dispose() {
    }

    /**
    Creates new instance of `ReplaySubject` that replays at most `bufferSize` last elements of sequence.
    
    - parameter bufferSize: Maximal number of elements to replay to observer after subscription.
    - returns: New instance of replay subject.
    */
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
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _disposed = false
    private var _stoppedEvent = nil as Event<Element>?
    private var _observers = Bag<AnyObserver<Element>>()
    
    override init() {
        
    }
    
    func trim() {
        abstractMethod()
    }
    
    func addValueToBuffer(value: Element) {
        abstractMethod()
    }
    
    func replayBuffer(observer: AnyObserver<Element>) {
        abstractMethod()
    }
    
    override func on(event: Event<Element>) {
        _lock.performLocked {
            if _disposed {
                return
            }
            
            if _stoppedEvent != nil {
                return
            }
            
            switch event {
            case .Next(let value):
                addValueToBuffer(value)
                trim()
                _observers.on(event)
            case .Error, .Completed:
                _stoppedEvent = event
                trim()
                _observers.on(event)
                _observers.removeAll()
            }
            
        }
    }
    
    override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        return _lock.calculateLocked {
            if _disposed {
                observer.on(.Error(RxError.DisposedError))
                return NopDisposable.instance
            }
         
            let AnyObserver = observer.asObserver()
            
            replayBuffer(AnyObserver)
            if let stoppedEvent = _stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            else {
                let key = _observers.insert(AnyObserver)
                return ReplaySubscription(subject: self, disposeKey: key)
            }
        }
    }
    
    override func unsubscribe(key: DisposeKey) {
        _lock.performLocked {
            if _disposed {
                return
            }
            
            _ = _observers.removeKey(key)
        }
    }

    func lockedDispose() {
        _disposed = true
        _stoppedEvent = nil
        _observers.removeAll()
    }
    
    override func dispose() {
        super.dispose()
        
        _lock.performLocked {
            lockedDispose()
        }
    }
}

class ReplayOne<Element> : ReplayBufferBase<Element> {
    private var _value: Element?
    
    override init() {
        super.init()
    }
    
    override func trim() {
        
    }
    
    override func addValueToBuffer(value: Element) {
        _value = value
    }
    
    override func replayBuffer(observer: AnyObserver<Element>) {
        if let value = _value {
            observer.on(.Next(value))
        }
    }
    
    override func lockedDispose() {
        super.lockedDispose()
        
        _value = nil
    }
}

class ReplayManyBase<Element> : ReplayBufferBase<Element> {
    private var _queue: Queue<Element>
    
    init(queueSize: Int) {
        _queue = Queue(capacity: queueSize + 1)
    }
    
    override func addValueToBuffer(value: Element) {
        _queue.enqueue(value)
    }
    
    override func replayBuffer(observer: AnyObserver<E>) {
        for item in _queue {
            observer.on(.Next(item))
        }
    }
    
    override func lockedDispose() {
        super.lockedDispose()
        _queue = Queue(capacity: 0)
    }
}

class ReplayMany<Element> : ReplayManyBase<Element> {
    private let _bufferSize: Int
    
    init(bufferSize: Int) {
        _bufferSize = bufferSize
        
        super.init(queueSize: bufferSize)
    }
    
    override func trim() {
        while _queue.count > _bufferSize {
            _queue.dequeue()
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
    
    private var _lock = SpinLock()
    
    // state
    private var _subject: Subject?
    private var _disposeKey: DisposeKey?
    
    init(subject: Subject, disposeKey: DisposeKey) {
        _subject = subject
        _disposeKey = disposeKey
    }
    
    func dispose() {
        let oldState = _lock.calculateLocked { () -> (Subject?, DisposeKey?) in
            let state = (self._subject, self._disposeKey)
            self._subject = nil
            self._disposeKey = nil
            
            return state
        }
        
        if let subject = oldState.0, let disposeKey = oldState.1 {
            subject.unsubscribe(disposeKey)
        }
    }
}
