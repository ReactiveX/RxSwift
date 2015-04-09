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
                self.subject.unsubscribe(self.key)
            }
        }
    }
}


public class Subject<Element> : SubjectType<Element, Element>, Disposable {
    typealias ObserverType = ObserverOf<Element>
    typealias KeyType = Bag<Void>.KeyType
    typealias Observers = Bag<ObserverType>
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
        }
    }
    
    public override func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next(let value):
            let observers = lock.calculateLocked { () -> [ObserverType]? in
                let state = self.state
                let shouldReturnImmediatelly = state.disposed || state.stoppedEvent != nil
                let observers: [ObserverType]? = shouldReturnImmediatelly ? nil : state.observers.all
                
                return observers
            }
            
            if let observers = observers {
                return dispatch(event, observers)
            }
            else {
                return SuccessResult
            }
        default:
            break
        }
        
        let observers: [ObserverType] = lock.calculateLocked {
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
        
        return dispatch(event, observers)
    }
    
    
    public override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        return lock.calculateLocked {
            if let stoppedEvent = state.stoppedEvent {
                return observer.on(stoppedEvent) >>> {
                    return success(DefaultDisposable())
                }
            }
            
            if state.disposed {
                return .Error(DisposedError)
            }
            
            let key = state.observers.put(observer)
            return success(Subscription(subject: self, key: key, observer: observer))
        }
    }

    func unsubscribe(key: KeyType) {
        self.lock.performLocked {
            let observer = state.observers.removeKey(key)
            if observer == nil {
                rxFatalError("Something went wrong with dispose")
            }
        }
    }
}