//
//  HotObservable.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// A representation of hot observable sequence.
///
/// Recorded events are replayed at absolute times no matter is there any subscriber.
///
/// Event times represent absolute `TestScheduler` time.
final class HotObservable<Element>
    : TestableObservable<Element> {

    typealias Observer = (Event<Element>) -> ()
    typealias Observers = Bag<Observer>

    /// Current subscribed observers.
    private var _observers: Observers

    override init(testScheduler: TestScheduler, recordedEvents: [Recorded<Event<Element>>]) {
        _observers = Observers()
        
        super.init(testScheduler: testScheduler, recordedEvents: recordedEvents)

        for recordedEvent in recordedEvents {
            testScheduler.scheduleAt(recordedEvent.time) { t in
                self._observers.forEach {
                    $0(recordedEvent.value)
                }
            }
        }
    }

    /// Subscribes `observer` to receive events for this sequence.
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        let key = _observers.insert(observer.on)
        subscriptions.append(Subscription(self.testScheduler.clock))
        
        let i = self.subscriptions.count - 1
        
        return Disposables.create {
            let removed = self._observers.removeKey(key)
            assert(removed != nil)
            
            let existing = self.subscriptions[i]
            self.subscriptions[i] = Subscription(existing.subscribe, self.testScheduler.clock)
        }
    }
}

