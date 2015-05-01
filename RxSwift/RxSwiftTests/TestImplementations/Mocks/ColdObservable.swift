//
//  ColdObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

class ColdObservable<Element: Equatable>: Observable<Element> {
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
    }
    
    override func subscribe(observer: ObserverOf<Element>) -> Disposable {
        let key = observers.put(observer)
        subscriptions.append(Subscription(subscribe: self.testScheduler.now))
        
        let i = self.subscriptions.count - 1

        for recordedEvent in recordedEvents {
            testScheduler.scheduleRelative((), dueTime: recordedEvent.time, action: { (Int) in
                self.observers.all.map { o in o.on(recordedEvent.event) }
                return SuccessResult
            })
        }
        
        return AnonymousDisposable {
            let removed = self.observers.removeKey(key)
            assert(removed != nil);
            
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self.testScheduler.now)
            
        }
    }
}