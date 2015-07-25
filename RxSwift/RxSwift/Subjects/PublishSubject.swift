//
//  PublishSubject.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Subscription<Element> : Disposable {
    typealias ObserverType = Observer<Element>
    typealias KeyType = Bag<Void>.KeyType
    
    private let subject: PublishSubject<Element>
    private var key: KeyType
    
    private var lock = SpinLock()
    private var observer: ObserverType?
    
    init(subject: PublishSubject<Element>, key: KeyType, observer: ObserverType) {
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

@availability(*, deprecated=1.7, message="Replaced by PublishSubject")
public class Subject<Element> : PublishSubject<Element> {
    
    public override init() {
        super.init()
    }
}

public class PublishSubject<Element> : SubjectType<Element, Element>, Cancelable {
    typealias ObserverOf = Observer<Element>
    typealias KeyType = Bag<Void>.KeyType
    typealias Observers = Bag<ObserverOf>

    typealias State = (
        disposed: Bool,
        observers: Observers,
        stoppedEvent: Event<Element>?
    )
    
    private var lock = SpinLock()
    private var state: State = (
        disposed: false,
        observers: Observers(),
        stoppedEvent: nil
    )
    
    public var disposed: Bool {
        get {
            return self.lock.calculateLocked {
                return state.disposed
            }
        }
    }
    
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
            let observers = lock.calculateLocked { () -> [ObserverOf]? in
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
        
        let observers: [Observer] = lock.calculateLocked { () -> [ObserverOf] in
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
                return NopDisposable.instance
            }
            
            if state.disposed {
                sendError(observer, DisposedError)
                return NopDisposable.instance
            }
            
            let key = state.observers.put(Observer.normalize(observer))
            return Subscription(subject: self, key: key, observer: Observer.normalize(observer))
        }
    }

    func unsubscribe(key: KeyType) {
        self.lock.performLocked {
            _ = state.observers.removeKey(key)
        }
    }
}