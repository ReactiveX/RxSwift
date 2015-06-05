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
    typealias Element = ElementType
    
    typealias Events = Recorded<Element>
    typealias Observer = ObserverOf<Element>
    
    var subscriptions: [Subscription]
    var observers: Bag<ObserverOf<Element>>
    
    override init() {
        self.subscriptions = []
        self.observers = Bag()
        
        super.init()
    }
    
    func on(event: Event<Element>) {
        dispatch(event, observers.all)
    }
    
    override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        let key = observers.put(ObserverOf(observer))
        subscriptions.append(SubscribedToHotObservable)
        
        let i = self.subscriptions.count - 1
        
        return AnonymousDisposable {
            let removed = self.observers.removeKey(key)
            assert(removed != nil)
            
            let existing = self.subscriptions[i]
            self.subscriptions[i] = UnsunscribedFromHotObservable
        }
    }
}

