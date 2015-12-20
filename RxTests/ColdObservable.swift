//
//  ColdObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/**
A representation of cold observable sequence.

Recorded events are replayed after subscription once per subscriber.

Event times represent relative offset to subscription time.
*/
public class ColdObservable<Element: Equatable>
    : ObservableType
    , ObservableConvertibleType {
    public typealias E = Element

    public typealias RecordedEvent = Recorded<Event<Element>>

    /**
     Parent test scheduler.
    */
    let _testScheduler: TestScheduler

    /**
     Subscriptions recorded during cold observable lifetime.
    */
    public private(set) var subscriptions: [Subscription]

    /**
     List of events to replay for each of the subscriber.

     Event times represent relative offset to subscription time.
    */
    public private(set) var recordedEvents: [RecordedEvent]

    init(testScheduler: TestScheduler, recordedEvents: [RecordedEvent]) {
        _testScheduler = testScheduler
        
        self.recordedEvents = recordedEvents
        self.subscriptions = []
    }

    /**
    Subscribes `observer` to receive events for this sequence.
    */
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        subscriptions.append(Subscription(self._testScheduler.now))
        
        let i = self.subscriptions.count - 1

        for recordedEvent in recordedEvents {
            _testScheduler.scheduleRelative((), dueTime: recordedEvent.time, action: { (_) in
                observer.on(recordedEvent.value)
                return NopDisposable.instance
            })
        }
        
        return AnonymousDisposable {
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self._testScheduler.now)
        }
    }
}