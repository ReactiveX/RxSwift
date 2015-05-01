//
//  Subject.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Subscription<Element> : Disposable {
    typealias ObserverType = ObserverOf<Element>
    typealias KeyType = Bag<Void>.KeyType
    
    private let subject : Subject<Element>
    private var key: KeyType
    
    
    private var lock = Lock()
    private var observer: ObserverType?
    
    init(subject: Subject<Element>, key: KeyType, observer: ObserverType) {
        self.key = key
        self.subject = subject
        self.observer = observer
    }
    
    func dispose() {
        lock.performLocked {
            if let observer = self.observer {
                self.observer = nil
                self.subject.unsubscribe(self.key)
            }
        }
    }
}


public class Subject<Element> : SubjectType<Element, Element>, Disposable {
    typealias Observer = ObserverOf<Element>
    typealias KeyType = Bag<Void>.KeyType
    typealias Observers = Bag<Observer>
    typealias State = (
        disposed: Bool,
        observers: Observers,
        stoppedEvent: Event<Element>?
    )
    
    private var lock = Lock()
    private var state: State = (
        disposed: false,
        observers: Observers(),
        stoppedEvent: nil
    )
    
    public override init() {
        super.init()
    }
    
    public func dispose() {
        self.lock.performLocked {
            state.disposed = true
            state.observers.removeAll()
        }
    }
    
    public override func on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            let observers = lock.calculateLocked { () -> [Observer]? in
                let state = self.state
                let shouldReturnImmediatelly = state.disposed || state.stoppedEvent != nil
                let observers: [Observer]? = shouldReturnImmediatelly ? nil : state.observers.all
                
                return observers
            }
            
            if let observers = observers {
                dispatch(event, observers)
            }
            return
        default:
            break
        }
        
        let observers: [Observer] = lock.calculateLocked {
            let state = self.state
            
            var observers = self.state.observers.all
            
            switch event {
            case .Completed: fallthrough
            case .Error:
                if state.stoppedEvent == nil {
                    self.state.stoppedEvent = event
                    self.state.observers.removeAll()
                }
            default:
                rxFatalError("Something went wrong")
            }
            
            return observers
        }
        
        dispatch(event, observers)
    }
    
    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        return lock.calculateLocked {
            if let stoppedEvent = state.stoppedEvent {
                observer.on(stoppedEvent)
                return DefaultDisposable()
            }
            
            if state.disposed {
                observer.on(.Error(DisposedError))
                return DefaultDisposable()
            }
            
            let key = state.observers.put(ObserverOf(observer))
            return Subscription(subject: self, key: key, observer: ObserverOf(observer))
        }
    }

    func unsubscribe(key: KeyType) {
        self.lock.performLocked {
            _ = state.observers.removeKey(key)
        }
    }
}