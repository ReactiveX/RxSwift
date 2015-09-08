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
    typealias Observer = ObserverOf<Element>
    
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
            testScheduler.schedule((), time: recordedEvent.time) { t in
                self.observers.forEach { $0.on(recordedEvent.event) }
                return NopDisposable.instance
            }
        }
    }
    
    override func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        let key = observers.insert(ObserverOf(observer))
        subscriptions.append(Subscription(self.testScheduler.now))
        
        let i = self.subscriptions.count - 1
        
        return AnonymousDisposable {
            let removed = self.observers.removeKey(key)
            assert(removed != nil)
            
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self.testScheduler.now)
        }
    }
}

