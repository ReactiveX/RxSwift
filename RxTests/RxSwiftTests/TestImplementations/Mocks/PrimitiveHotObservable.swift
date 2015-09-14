//
//  PrimitiveHotObservable.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 6/4/15.
//
//

import Foundation
import RxSwift

let SubscribedToHotObservable = Subscription(0)
let UnsunscribedFromHotObservable = Subscription(0, 0)

class PrimitiveHotObservable<ElementType : Equatable> : Observable<ElementType>, ObserverType {
    typealias Events = Recorded<E>
    typealias Observer = ObserverOf<E>
    
    var subscriptions: [Subscription]
    var observers: Bag<ObserverOf<E>>
    
    override init() {
        self.subscriptions = []
        self.observers = Bag()
        
        super.init()
    }
    
    func on(event: Event<E>) {
        observers.forEach { $0.on(event) }
    }
    
    override func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        let key = observers.insert(ObserverOf(observer))
        subscriptions.append(SubscribedToHotObservable)
        
        let i = self.subscriptions.count - 1
        
        return AnonymousDisposable {
            let removed = self.observers.removeKey(key)
            assert(removed != nil)
            
            self.subscriptions[i] = UnsunscribedFromHotObservable
        }
    }
}

