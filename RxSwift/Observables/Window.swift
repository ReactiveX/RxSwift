//
//  Window.swift
//  RxSwift
//
//  Created by Junior B. on 29/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public extension ObservableType {
    /**
     Projects each element of an observable sequence into a window that is completed when either it’s full or a given amount of time has elapsed.

     - seealso: [window operator on reactivex.io](http://reactivex.io/documentation/operators/window.html)

     - parameter timeSpan: Maximum time length of a window.
     - parameter count: Maximum element count of a window.
     - parameter scheduler: Scheduler to run windowing timers on.
     - returns: An observable sequence of windows (instances of `Observable`).
     */
    func window(timeSpan: RxTimeInterval, count: Int, scheduler: SchedulerType)
        -> Observable<Observable<Element>>
    {
        WindowTimeCount(source: asObservable(), timeSpan: timeSpan, count: count, scheduler: scheduler)
    }
}

private final class WindowTimeCountSink<Element, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType,
    LockOwnerType,
    SynchronizedOnType where Observer.Element == Observable<Element>
{
    typealias Parent = WindowTimeCount<Element>

    private let parent: Parent

    let lock = RecursiveLock()

    private var subject = PublishSubject<Element>()
    private var count = 0
    private var windowId = 0

    private let timerD = SerialDisposable()
    private let refCountDisposable: RefCountDisposable
    private let groupDisposable = CompositeDisposable()

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent

        _ = groupDisposable.insert(timerD)

        refCountDisposable = RefCountDisposable(disposable: groupDisposable)
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        forwardOn(.next(AddRef(source: subject, refCount: refCountDisposable).asObservable()))
        createTimer(windowId)

        _ = groupDisposable.insert(parent.source.subscribe(self))
        return refCountDisposable
    }

    func startNewWindowAndCompleteCurrentOne() {
        subject.on(.completed)
        subject = PublishSubject<Element>()

        forwardOn(.next(AddRef(source: subject, refCount: refCountDisposable).asObservable()))
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        var newWindow = false
        var newId = 0

        switch event {
        case let .next(element):
            subject.on(.next(element))

            do {
                _ = try incrementChecked(&count)
            } catch let e {
                self.subject.on(.error(e as Swift.Error))
                self.dispose()
            }

            if count == parent.count {
                newWindow = true
                count = 0
                windowId += 1
                newId = windowId
                startNewWindowAndCompleteCurrentOne()
            }

        case let .error(error):
            subject.on(.error(error))
            forwardOn(.error(error))
            dispose()

        case .completed:
            subject.on(.completed)
            forwardOn(.completed)
            dispose()
        }

        if newWindow {
            createTimer(newId)
        }
    }

    func createTimer(_ windowId: Int) {
        if timerD.isDisposed {
            return
        }

        if self.windowId != windowId {
            return
        }

        let nextTimer = SingleAssignmentDisposable()

        timerD.disposable = nextTimer

        let scheduledRelative = parent.scheduler.scheduleRelative(windowId, dueTime: parent.timeSpan) { previousWindowId in
            var newId = 0

            self.lock.performLocked {
                if previousWindowId != self.windowId {
                    return
                }

                self.count = 0
                self.windowId = self.windowId &+ 1
                newId = self.windowId
                self.startNewWindowAndCompleteCurrentOne()
            }

            self.createTimer(newId)

            return Disposables.create()
        }

        nextTimer.setDisposable(scheduledRelative)
    }
}

private final class WindowTimeCount<Element>: Producer<Observable<Element>> {
    fileprivate let timeSpan: RxTimeInterval
    fileprivate let count: Int
    fileprivate let scheduler: SchedulerType
    fileprivate let source: Observable<Element>

    init(source: Observable<Element>, timeSpan: RxTimeInterval, count: Int, scheduler: SchedulerType) {
        self.source = source
        self.timeSpan = timeSpan
        self.count = count
        self.scheduler = scheduler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Observable<Element> {
        let sink = WindowTimeCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
