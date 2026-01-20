//
//  Just.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    static func just(_ element: Element) -> Observable<Element> {
        Just(element: element)
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - parameter scheduler: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> Observable<Element> {
        JustScheduled(element: element, scheduler: scheduler)
    }
}

private final class JustScheduledSink<Observer: ObserverType>: Sink<Observer> {
    typealias Parent = JustScheduled<Observer.Element>

    private let parent: Parent

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        let scheduler = parent.scheduler
        return scheduler.schedule(parent.element) { element in
            self.forwardOn(.next(element))
            return scheduler.schedule(()) { _ in
                self.forwardOn(.completed)
                self.dispose()
                return Disposables.create()
            }
        }
    }
}

private final class JustScheduled<Element>: Producer<Element> {
    fileprivate let scheduler: ImmediateSchedulerType
    fileprivate let element: Element

    init(element: Element, scheduler: ImmediateSchedulerType) {
        self.scheduler = scheduler
        self.element = element
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = JustScheduledSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

private final class Just<Element>: Producer<Element> {
    private let element: Element

    init(element: Element) {
        self.element = element
    }

    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        observer.on(.next(element))
        observer.on(.completed)
        return Disposables.create()
    }
}
