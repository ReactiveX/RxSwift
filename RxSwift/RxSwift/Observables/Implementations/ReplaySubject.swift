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
    
    var lock = Lock()
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
    
    
    var lock = Lock()
    
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
    
    func replayBuffer(observer: Observer) -> Result<Void> {
        return abstractMethod()
    }
    
    override var hasObservers: Bool {
        get {
            return state.observers.count > 0
        }
    }
    
    override func on(event: Event<Element>) -> Result<Void> {
        return lock.calculateLocked {
            if self.state.disposed {
                return .Error(DisposedError)
            }
            
            if self.state.stoppedEvent != nil {
                return success([])
            }
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                addValueToBuffer(value)
                trim()
                return success(self.state.observers.all)
            case .Error: fallthrough
            case .Completed:
                state.stoppedEvent = event
                trim()
                var bag = self.state.observers
                var observers = bag.all
                bag.removeAll()
                return success(observers)
            }
        } >== { observers in
            return dispatch(event, observers)
        }
    }
    
    override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        return lock.calculateLocked {
            if self.state.disposed {
                return .Error(DisposedError)
            }
            
            return replayBuffer(observer) >== {
                if let stoppedEvent = self.state.stoppedEvent {
                    return observer.on(stoppedEvent) >>> { success(DefaultDisposable()) }
                }
                else {
                    let key = self.state.observers.put(observer)
                    return success(ReplaySubscription(subject: self, disposeKey: key))
                }
            }
        }
    }
    
    override func unsubscribe(key: DisposeKey) {
        lock.performLocked {
            if self.state.disposed {
                return
            }
            
            let observer = self.state.observers.removeKey(key)
            if observer == nil {
                removingObserverFailed()
            }
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
    
    override func trim() {
        
    }
    
    override func addValueToBuffer(value: Element) {
        self.value = value
    }
    
    override func replayBuffer(observer: Observer) -> Result<Void> {
        if let value = self.value {
            return observer.on(.Next(Box(value)))
        }
        else {
            return SuccessResult
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
    
    override func replayBuffer(observer: Observer) -> Result<Void> {
        var result = SuccessResult
        for item in queue {
            result = result >>> {
                observer.on(.Next(Box(item)))
            }
        }
        
        return result
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

class ReplaySubject<Element> : SubjectType<Element, Element> {
    typealias Observer = ObserverOf<Element>
    typealias BagType = Bag<Observer>
    typealias DisposeKey = BagType.KeyType
    
    let implementation: ReplaySubjectImplementation<Element>
    
    init(bufferSize: UInt) {
        if bufferSize == 1 {
            implementation = ReplayOne()
        }
        else {
            rxFatalError("Only replay one is supported for now")
            implementation = ReplayOne()
        }
    }
    
    override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        return implementation.subscribe(observer)
    }
    
    override func on(event: Event<Element>) -> Result<Void> {
        return implementation.on(event)
    }
}