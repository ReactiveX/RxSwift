//
//  PrimitiveHotObservable.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 6/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxTests

let SubscribedToHotObservable = Subscription(0)
let UnsunscribedFromHotObservable = Subscription(0, 0)

class PrimitiveHotObservable<ElementType> : ObservableType {
    typealias E = ElementType

    typealias Events = Recorded<E>
    typealias Observer = AnyObserver<E>
    
    var subscriptions: [Subscription]
    var observers: Bag<AnyObserver<E>>

    let lock = NSRecursiveLock()
    
    init() {
        self.subscriptions = []
        self.observers = Bag()
    }
    
    func on(event: Event<E>) {
        lock.lock()
        defer { lock.unlock() }
        observers.on(event)
    }
    
    func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        lock.lock()
        defer { lock.unlock() }

        let key = observers.insert(AnyObserver(observer))
        subscriptions.append(SubscribedToHotObservable)
        
        let i = self.subscriptions.count - 1
        
        return AnonymousDisposable {
            self.lock.lock()
            defer { self.lock.unlock() }
            
            let removed = self.observers.removeKey(key)
            assert(removed != nil)
            
            self.subscriptions[i] = UnsunscribedFromHotObservable
        }
    }
}

