//
//  PrimitiveHotObservable.swift
//  Tests
//
//  Created by Krunoslav Zaher on 6/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest
import Dispatch

let SubscribedToHotObservable = Subscription(0)
let UnsunscribedFromHotObservable = Subscription(0, 0)

class PrimitiveHotObservable<ElementType> : ObservableType {
    typealias E = ElementType

    typealias Events = Recorded<E>
    typealias Observer = AnyObserver<E>
    
    var subscriptions = [Subscription]()
    let observers = PublishSubject<ElementType>()

    let lock = RecursiveLock()
    
    init() {
    }

    func on(_ event: Event<E>) {
        lock.lock()
        defer { lock.unlock() }
        observers.on(event)
    }
    
    func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        lock.lock()
        defer { lock.unlock() }

        let removeObserver = observers.subscribe(observer)
        subscriptions.append(SubscribedToHotObservable)

        let i = self.subscriptions.count - 1

        var count = 0
        
        return Disposables.create {
            self.lock.lock()
            defer { self.lock.unlock() }

            removeObserver.dispose()
            count += 1
            assert(count == 1)
            
            self.subscriptions[i] = UnsunscribedFromHotObservable
        }
    }
}

