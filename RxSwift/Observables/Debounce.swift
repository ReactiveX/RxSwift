//
//  Debounce.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/11/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public extension ObservableType {
    /**
     Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.

     - seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

     - parameter dueTime: Throttling duration for each element.
     - parameter scheduler: Scheduler to run the throttle timers on.
     - returns: The throttled sequence.
     */
    func debounce(_ dueTime: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element>
    {
        Debounce(source: asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

private final class DebounceSink<Observer: ObserverType>:
    Sink<Observer>,
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias Element = Observer.Element
    typealias ParentType = Debounce<Element>

    private let parent: ParentType

    let lock = RecursiveLock()

    // state
    private var id = 0 as UInt64
    private var value: Element?

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
            id = id &+ 1
            let currentId = id
            value = element

            let scheduler = parent.scheduler
            let dueTime = parent.dueTime

            let d = SingleAssignmentDisposable()
            cancellable.disposable = d
            d.setDisposable(scheduler.scheduleRelative(currentId, dueTime: dueTime, action: propagate))
        case .error:
            value = nil
            forwardOn(event)
            dispose()
        case .completed:
            if let value {
                self.value = nil
                forwardOn(.next(value))
            }
            forwardOn(.completed)
            dispose()
        }
    }

    func propagate(_ currentId: UInt64) -> Disposable {
        lock.performLocked {
            let originalValue = self.value

            if let value = originalValue, self.id == currentId {
                self.value = nil
                self.forwardOn(.next(value))
            }

            return Disposables.create()
        }
    }
}

private final class Debounce<Element>: Producer<Element> {
    fileprivate let source: Observable<Element>
    fileprivate let dueTime: RxTimeInterval
    fileprivate let scheduler: SchedulerType

    init(source: Observable<Element>, dueTime: RxTimeInterval, scheduler: SchedulerType) {
        self.source = source
        self.dueTime = dueTime
        self.scheduler = scheduler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = DebounceSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
