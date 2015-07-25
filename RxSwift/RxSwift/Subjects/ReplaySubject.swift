//
//  ReplaySubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ReplaySubjectImplementation<Element> : SubjectType<Element, Element>, Disposable {
    typealias Observer = ObserverOf<Element>
    typealias BagType = Bag<Observer>
    typealias DisposeKey = BagType.KeyType
    
    var hasObservers: Bool {
        get {
            return abstractMethod()
        }
    }
        
    func unsubscribe(key: DisposeKey) {
        return abstractMethod()
    }
    
    func dispose() {
        
    }
}

class ReplaySubscription<Element> : Disposable {
    typealias Observer = ObserverOf<Element>
    typealias BagType = Bag<Observer>
    typealias DisposeKey = BagType.KeyType
    typealias Subject = ReplaySubjectImplementation<Element>
    typealias State = (
        subject: Subject?,
        disposeKey: DisposeKey?
    )
    
    var lock = SpinLock()
    var state: State
    
    init(subject: Subject, disposeKey: DisposeKey) {
        self.state = (
            subject: subject,
            disposeKey: disposeKey
        )
    }
    
    func dispose() {
        let oldState = lock.calculateLocked { () -> State in
            var state = self.state
            self.state = (
                subject: nil,
                disposeKey: nil
            )
            
            return state
        }
        
        if let subject = oldState.subject, disposeKey = oldState.disposeKey {
            subject.unsubscribe(disposeKey)
        }
    }
}

class ReplayBufferBase<Element> : ReplaySubjectImplementation<Element> {
    typealias Observer = ObserverOf<Element>
    typealias BagType = Bag<Observer>
    typealias DisposeKey = BagType.KeyType
    
    typealias State = (
        disposed: Bool,
        stoppedEvent: Event<Element>?,
        observers: BagType
    )
    
    
    var lock = SpinLock()
    
    var state: State = (
        disposed: false,
        stoppedEvent: nil,
        observers: Bag()
    )
    
    override init() {
        
    }
    
    func trim() {
        return abstractMethod()
    }
    
    func addValueToBuffer(value: Element) {
        return abstractMethod()
    }
    
    func replayBuffer(observer: Observer) {
        return abstractMethod()
    }
    
    override var hasObservers: Bool {
        get {
            return state.observers.count > 0
        }
    }
    
    override func on(event: Event<Element>) {
        let observers: [Observer] = lock.calculateLocked {
            if self.state.disposed {
                return []
            }
            
            if self.state.stoppedEvent != nil {
                return []
            }
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                addValueToBuffer(value)
                trim()
                return self.state.observers.all
            case .Error: fallthrough
            case .Completed:
                state.stoppedEvent = event
                trim()
                var bag = self.state.observers
                var observers = bag.all
                bag.removeAll()
                return observers
            }
        }
        
        dispatch(event, observers)
    }
    
    override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        return lock.calculateLocked {
            if self.state.disposed {
                sendError(observer, DisposedError)
                return NopDisposable.instance
            }
         
            let observerOf = ObserverOf(observer)
            
            replayBuffer(observerOf)
            if let stoppedEvent = self.state.stoppedEvent {
                observer.on(stoppedEvent)
                return NopDisposable.instance
            }
            else {
                let key = self.state.observers.put(observerOf)
                return ReplaySubscription(subject: self, disposeKey: key)
            }
        }
    }
    
    override func unsubscribe(key: DisposeKey) {
        lock.performLocked {
            if self.state.disposed {
                return
            }
            
            _ = self.state.observers.removeKey(key)
        }
    }

    func lockedDispose() {
        state.disposed = true
        state.observers.removeAll()
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
    
    init(firstElement: Element) {
        self.value = firstElement
        super.init()
    }
    
    override init() {
        super.init()
    }
    
    override func trim() {
        
    }
    
    override func addValueToBuffer(value: Element) {
        self.value = value
    }
    
    override func replayBuffer(observer: Observer) {
        if let value = self.value {
            sendNext(observer, value)
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
    
    override func replayBuffer(observer: Observer) {
        for item in queue {
            sendNext(observer, item)
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

public class ReplaySubject<Element> : SubjectType<Element, Element> {
    typealias Observer = ObserverOf<Element>
    typealias BagType = Bag<Observer>
    typealias DisposeKey = BagType.KeyType
    
    let implementation: ReplaySubjectImplementation<Element>
    
    public init(bufferSize: Int) {
        if bufferSize == 1 {
            implementation = ReplayOne()
        }
        else {
            implementation = ReplayMany(bufferSize: bufferSize)
        }
    }
    
    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        return implementation.subscribe(observer)
    }
    
    public override func on(event: Event<Element>) {
        implementation.on(event)
    }
}