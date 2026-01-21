//
//  Throttle.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public extension ObservableType {
    /**
     Returns an Observable that emits the first and the latest item emitted by the source Observable during sequential time windows of a specified duration.

     This operator makes sure that no two elements are emitted in less then dueTime.

     - seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

     - parameter dueTime: Throttling duration for each element.
     - parameter latest: Should latest element received in a dueTime wide time window since last element emission be emitted.
     - parameter scheduler: Scheduler to run the throttle timers on.
     - returns: The throttled sequence.
     */
    func throttle(_ dueTime: RxTimeInterval, latest: Bool = true, scheduler: SchedulerType)
        -> Observable<Element>
    {
        Throttle(source: asObservable(), dueTime: dueTime, latest: latest, scheduler: scheduler)
    }
}

private final class ThrottleSink<Observer: ObserverType>:
    Sink<Observer>,
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Element = Observer.Element
    typealias ParentType = Throttle<Element>

    private let parent: ParentType

    let lock = RecursiveLock()

    // state
    private var lastUnsentElement: Element?
    private var lastSentTime: Date?
    private var completed: Bool = false

    let cancellable = SerialDisposable()

    init(parent: ParentType, observer: Observer, cancel: Cancelable) {
        self.parent = parent

        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        let subscription = parent.source.subscribe(self)

        return Disposables.create(subscription, cancellable)
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case let .next(element):
            let now = parent.scheduler.now

            let reducedScheduledTime: RxTimeInterval = if let lastSendingTime = lastSentTime {
                parent.dueTime.reduceWithSpanBetween(earlierDate: lastSendingTime, laterDate: now)
            } else {
                .nanoseconds(0)
            }

            if reducedScheduledTime.isNow {
                sendNow(element: element)
                return
            }

            if !parent.latest {
                return
            }

            let isThereAlreadyInFlightRequest = lastUnsentElement != nil

            lastUnsentElement = element

            if isThereAlreadyInFlightRequest {
                return
            }

            let scheduler = parent.scheduler

            let d = SingleAssignmentDisposable()
            cancellable.disposable = d

            d.setDisposable(scheduler.scheduleRelative(0, dueTime: reducedScheduledTime, action: propagate))
        case .error:
            lastUnsentElement = nil
            forwardOn(event)
            dispose()
        case .completed:
            if lastUnsentElement != nil {
                completed = true
            } else {
                forwardOn(.completed)
                dispose()
            }
        }
    }

    private func sendNow(element: Element) {
        lastUnsentElement = nil
        forwardOn(.next(element))
        // in case element processing takes a while, this should give some more room
        lastSentTime = parent.scheduler.now
    }

    func propagate(_: Int) -> Disposable {
        lock.performLocked {
            if let lastUnsentElement = self.lastUnsentElement {
                self.sendNow(element: lastUnsentElement)
            }

            if self.completed {
                self.forwardOn(.completed)
                self.dispose()
            }
        }

        return Disposables.create()
    }
}

private final class Throttle<Element>: Producer<Element> {
    fileprivate let source: Observable<Element>
    fileprivate let dueTime: RxTimeInterval
    fileprivate let latest: Bool
    fileprivate let scheduler: SchedulerType

    init(source: Observable<Element>, dueTime: RxTimeInterval, latest: Bool, scheduler: SchedulerType) {
        self.source = source
        self.dueTime = dueTime
        self.latest = latest
        self.scheduler = scheduler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = ThrottleSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
