//
//  HotObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class HotObservable<Element : Equatable> : ObservableType, ObservableConvertibleType {
    typealias E = Element
    
    typealias Events = Recorded<Element>
    typealias Observer = AnyObserver<Element>
    
    let testScheduler: TestScheduler
    
    var subscriptions: [Subscription]
    var recordedEvents: [Events]
    var observers: Bag<AnyObserver<Element>>

    init(testScheduler: TestScheduler, recordedEvents: [Events]) {
        self.testScheduler = testScheduler
        
        self.recordedEvents = recordedEvents
        self.subscriptions = []
        self.observers = Bag()
        
        for recordedEvent in recordedEvents {
            testScheduler.schedule((), time: recordedEvent.time) { t in
                self.observers.on(recordedEvent.event)
                return NopDisposable.instance
            }
        }
    }
    
    func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        let key = observers.insert(AnyObserver(observer))
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

