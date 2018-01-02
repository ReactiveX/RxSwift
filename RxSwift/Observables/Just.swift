//
//  Just.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: E) -> Observable<E> {
        return Just(element: element)
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - parameter: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: E, scheduler: ImmediateSchedulerType) -> Observable<E> {
        return JustScheduled(element: element, scheduler: scheduler)
    }
}

final fileprivate class JustScheduled<Element> : Producer<Element> {
    fileprivate let _scheduler: ImmediateSchedulerType
    fileprivate let _element: Element

    init(element: Element, scheduler: ImmediateSchedulerType) {
        _scheduler = scheduler
        _element = element
    }

    override func run(_ observer: Observer<E>, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {

        let sink = Sink(observer: observer, cancel: cancel)
        let scheduler = _scheduler

        let subscription = scheduler.schedule(_element) { element in
                sink.forwardOn(.next(element))
                return scheduler.schedule(()) { _ in
                    sink.forwardOn(.completed)
                    sink.dispose()
                    return Disposables.create()
                }
            }

        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class Just<Element> : Producer<Element> {
    private let _element: Element
    
    init(element: Element) {
        _element = element
    }
    
    override func subscribe(_ observer: Observer<Element>) -> Disposable {
        observer.on(.next(_element))
        observer.on(.completed)
        return Disposables.create()
    }
}
