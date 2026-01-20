//
//  DelaySubscription.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public extension ObservableType {
    /**
     Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the subscription.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: Time-shifted sequence.
     */
    func delaySubscription(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element>
    {
        DelaySubscription(source: asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

private final class DelaySubscriptionSink<Observer: ObserverType>:
    Sink<Observer>, ObserverType
{
    typealias Element = Observer.Element

    func on(_ event: Event<Element>) {
        forwardOn(event)
        if event.isStopEvent {
            dispose()
        }
    }
}

private final class DelaySubscription<Element>: Producer<Element> {
    private let source: Observable<Element>
    private let dueTime: RxTimeInterval
    private let scheduler: SchedulerType

    init(source: Observable<Element>, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        self.source = source
        self.dueTime = dueTime
        self.scheduler = scheduler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = DelaySubscriptionSink(observer: observer, cancel: cancel)
        let subscription = scheduler.scheduleRelative((), dueTime: dueTime) { _ in
            self.source.subscribe(sink)
        }

        return (sink: sink, subscription: subscription)
    }
}
