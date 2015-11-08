//
//  ColdObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

class ColdObservable<Element: Equatable> : ObservableType, ObservableConvertibleType {
    typealias E = Element

    typealias Events = Recorded<Element>
    typealias Observer = AnyObserver<Element>
    
    let testScheduler: TestScheduler
    
    var subscriptions: [Subscription]
    var recordedEvents: [Events]

    init(testScheduler: TestScheduler, recordedEvents: [Events]) {
        self.testScheduler = testScheduler
        
        self.recordedEvents = recordedEvents
        self.subscriptions = []
    }
    
    func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        subscriptions.append(Subscription(self.testScheduler.now))
        
        let i = self.subscriptions.count - 1

        for recordedEvent in recordedEvents {
            testScheduler.scheduleRelative((), dueTime: recordedEvent.time, action: { (_) in
                observer.on(recordedEvent.event)
                return NopDisposable.instance
            })
        }
        
        return AnonymousDisposable {
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self.testScheduler.now)
        }
    }
}