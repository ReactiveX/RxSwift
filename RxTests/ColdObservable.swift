//
//  ColdObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

public class ColdObservable<Element: Equatable>
    : ObservableType
    , ObservableConvertibleType {
    public typealias E = Element

    public typealias Events = Recorded<Event<Element>>
    
    public let testScheduler: TestScheduler
    
    public private(set) var subscriptions: [Subscription]
    public private(set) var recordedEvents: [Events]

    init(testScheduler: TestScheduler, recordedEvents: [Events]) {
        self.testScheduler = testScheduler
        
        self.recordedEvents = recordedEvents
        self.subscriptions = []
    }
    
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        subscriptions.append(Subscription(self.testScheduler.now))
        
        let i = self.subscriptions.count - 1

        for recordedEvent in recordedEvents {
            testScheduler.scheduleRelative((), dueTime: recordedEvent.time, action: { (_) in
                observer.on(recordedEvent.value)
                return NopDisposable.instance
            })
        }
        
        return AnonymousDisposable {
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self.testScheduler.now)
        }
    }
}