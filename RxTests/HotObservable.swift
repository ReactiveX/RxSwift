//
//  HotObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
 A representation of hot observable sequence.

 Recorded events are replayed at absolute times no matter is there any subscriber.

 Event times represent absolute `TestScheduler` time.
 */
class HotObservable<Element>
    : TestableObservable<Element> {
    typealias Observer = AnyObserver<Element>

    /**
     Current subscribed observers.
    */
    private var _observers: Bag<AnyObserver<Element>>

    override init(testScheduler: TestScheduler, recordedEvents: [Recorded<Event<Element>>]) {
        _observers = Bag()
        
        super.init(testScheduler: testScheduler, recordedEvents: recordedEvents)

        for recordedEvent in recordedEvents {
            testScheduler.scheduleAt(recordedEvent.time) { t in
                self._observers.on(recordedEvent.value)
            }
        }
    }

    /**
     Subscribes `observer` to receive events for this sequence.
     */
    override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        let key = _observers.insert(AnyObserver(observer))
        subscriptions.append(Subscription(self.testScheduler.clock))
        
        let i = self.subscriptions.count - 1
        
        return AnonymousDisposable {
            let removed = self._observers.removeKey(key)
            assert(removed != nil)
            
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self.testScheduler.clock)
        }
    }
}

