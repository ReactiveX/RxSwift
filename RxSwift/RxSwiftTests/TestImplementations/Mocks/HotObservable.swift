//
//  HotObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class HotObservable<Element : Equatable> : Observable<Element> {
    typealias Events = Recorded<Element>
    typealias ObserverType = ObserverOf<Element>
    
    let testScheduler: TestScheduler
    
    var subscriptions: [Subscription]
    var recordedEvents: [Events]
    var observers: Bag<ObserverOf<Element>>

    init(testScheduler: TestScheduler, recordedEvents: [Events]) {
        self.testScheduler = testScheduler
        
        self.recordedEvents = recordedEvents
        self.subscriptions = []
        self.observers = Bag()
        
        super.init()
        
        for recordedEvent in recordedEvents {
            testScheduler.schedule((), date: recordedEvent.time, action: { (Int) in
                return doAll(self.observers.all.map { o in o.on(recordedEvent.event) })
            })
        }
    }
    
    override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        let key = observers.put(observer)
        subscriptions.append(Subscription(subscribe: self.testScheduler.now))
        
        let i = self.subscriptions.count - 1
        
        return success(AnonymousDisposable { 
            let removed = self.observers.removeKey(key)
            assert(removed != nil)
            
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self.testScheduler.now)
        })
    }
}

public func == <T>(lhs: Observable<T>, rhs: Observable<T>) -> Bool {
    return lhs === rhs
}