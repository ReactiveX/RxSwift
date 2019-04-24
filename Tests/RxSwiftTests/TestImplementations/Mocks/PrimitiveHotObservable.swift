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

class PrimitiveHotObservable<Element> : ObservableType {
    typealias Events = Recorded<Element>
    typealias Observer = AnyObserver<Element>
    
    var _subscriptions = [Subscription]()
    let _observers = PublishSubject<Element>()
    
    public var subscriptions: [Subscription] {
        lock.lock()
        defer { lock.unlock() }
        return _subscriptions
    }

    let lock = RecursiveLock()
    
    init() {
    }

    func on(_ event: Event<Element>) {
        lock.lock()
        defer { lock.unlock() }
        _observers.on(event)
    }
    
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        lock.lock()
        defer { lock.unlock() }

        let removeObserver = _observers.subscribe(observer)
        _subscriptions.append(SubscribedToHotObservable)

        let i = self._subscriptions.count - 1

        var count = 0
        
        return Disposables.create {
            self.lock.lock()
            defer { self.lock.unlock() }

            removeObserver.dispose()
            count += 1
            assert(count == 1)
            
            self._subscriptions[i] = UnsunscribedFromHotObservable
        }
    }
}

