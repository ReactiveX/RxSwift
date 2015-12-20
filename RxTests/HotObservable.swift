//
//  HotObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
 A representation of hot observable sequence.

 Recorded events are replayed at absolute times no matter is there any subscriber.

 Event times represent absolute `TestScheduler` time.
 */
public class HotObservable<Element : Equatable>
    : ObservableType
    , ObservableConvertibleType {
    public typealias E = Element
    public typealias Events = Recorded<Event<Element>>

    typealias Observer = AnyObserver<Element>

    /**
     Parent test scheduler.
     */
    private let _testScheduler: TestScheduler

    /**
     Current subscribed observers.
    */
    private var _observers: Bag<AnyObserver<Element>>

    /**
     Subscriptions recorded during hot observable lifetime.
    */
    public private(set) var subscriptions: [Subscription]

    /**
     List of events to replay for all subscribers.
     
     Event times represent absolute `TestScheduler` time.
    */
    public private(set) var recordedEvents: [Events]

    init(testScheduler: TestScheduler, recordedEvents: [Events]) {
        _testScheduler = testScheduler
        _observers = Bag()
        
        self.recordedEvents = recordedEvents
        self.subscriptions = []

        for recordedEvent in recordedEvents {
            testScheduler.schedule((), time: recordedEvent.time) { t in
                self._observers.on(recordedEvent.value)
                return NopDisposable.instance
            }
        }
    }

    /**
     Subscribes `observer` to receive events for this sequence.
     */
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        let key = _observers.insert(AnyObserver(observer))
        subscriptions.append(Subscription(self._testScheduler.now))
        
        let i = self.subscriptions.count - 1
        
        return AnonymousDisposable {
            let removed = self._observers.removeKey(key)
            assert(removed != nil)
            
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self._testScheduler.now)
        }
    }
}

