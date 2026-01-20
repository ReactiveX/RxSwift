//
//  Delay.swift
//  RxSwift
//
//  Created by tarunon on 2016/02/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public extension ObservableType {
    /**
     Returns an observable sequence by the source observable sequence shifted forward in time by a specified delay. Error events from the source observable sequence are not delayed.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the source by.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: the source Observable shifted in time by the specified delay.
     */
    func delay(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element>
    {
        Delay(source: asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

private final class DelaySink<Observer: ObserverType>:
    Sink<Observer>,
    ObserverType
{
    typealias Element = Observer.Element
    typealias Source = Observable<Element>
    typealias DisposeKey = Bag<Disposable>.KeyType

    private let lock = RecursiveLock()

    private let dueTime: RxTimeInterval
    private let scheduler: SchedulerType

    private let sourceSubscription = SingleAssignmentDisposable()
    private let cancelable = SerialDisposable()

    // is scheduled some action
    private var active = false
    // is "run loop" on different scheduler running
    private var running = false
    private var errorEvent: Event<Element>?

    // state
    private var queue = Queue<(eventTime: RxTime, event: Event<Element>)>(capacity: 0)

    init(observer: Observer, dueTime: RxTimeInterval, scheduler: SchedulerType, cancel: Cancelable) {
        self.dueTime = dueTime
        self.scheduler = scheduler
        super.init(observer: observer, cancel: cancel)
    }

    // All of these complications in this method are caused by the fact that
    // error should be propagated immediately. Error can be potentially received on different
    // scheduler so this process needs to be synchronized somehow.
    //
    // Another complication is that scheduler is potentially concurrent so internal queue is used.
    func drainQueue(state _: (), scheduler: AnyRecursiveScheduler<Void>) {
        lock.lock()
        let hasFailed = errorEvent != nil
        if !hasFailed {
            running = true
        }
        lock.unlock()

        if hasFailed {
            return
        }

        var ranAtLeastOnce = false

        while true {
            lock.lock()
            let errorEvent = errorEvent

            let eventToForwardImmediately = ranAtLeastOnce ? nil : queue.dequeue()?.event
            let nextEventToScheduleOriginalTime: Date? = ranAtLeastOnce && !queue.isEmpty ? queue.peek().eventTime : nil

            if errorEvent == nil {
                if eventToForwardImmediately != nil {}
                else if nextEventToScheduleOriginalTime != nil {
                    running = false
                } else {
                    running = false
                    active = false
                }
            }
            lock.unlock()

            if let errorEvent {
                forwardOn(errorEvent)
                dispose()
                return
            } else {
                if let eventToForwardImmediately {
                    ranAtLeastOnce = true
                    forwardOn(eventToForwardImmediately)
                    if case .completed = eventToForwardImmediately {
                        dispose()
                        return
                    }
                } else if let nextEventToScheduleOriginalTime {
                    scheduler.schedule((), dueTime: dueTime.reduceWithSpanBetween(earlierDate: nextEventToScheduleOriginalTime, laterDate: self.scheduler.now))
                    return
                } else {
                    return
                }
            }
        }
    }

    func on(_ event: Event<Element>) {
        if event.isStopEvent {
            sourceSubscription.dispose()
        }

        switch event {
        case .error:
            lock.lock()
            let shouldSendImmediately = !running
            queue = Queue(capacity: 0)
            errorEvent = event
            lock.unlock()

            if shouldSendImmediately {
                forwardOn(event)
                dispose()
            }
        default:
            lock.lock()
            let shouldSchedule = !active
            active = true
            queue.enqueue((scheduler.now, event))
            lock.unlock()

            if shouldSchedule {
                cancelable.disposable = scheduler.scheduleRecursive((), dueTime: dueTime, action: drainQueue)
            }
        }
    }

    func run(source: Observable<Element>) -> Disposable {
        sourceSubscription.setDisposable(source.subscribe(self))
        return Disposables.create(sourceSubscription, cancelable)
    }
}

private final class Delay<Element>: Producer<Element> {
    private let source: Observable<Element>
    private let dueTime: RxTimeInterval
    private let scheduler: SchedulerType

    init(source: Observable<Element>, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        self.source = source
        self.dueTime = dueTime
        self.scheduler = scheduler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = DelaySink(observer: observer, dueTime: dueTime, scheduler: scheduler, cancel: cancel)
        let subscription = sink.run(source: source)
        return (sink: sink, subscription: subscription)
    }
}
