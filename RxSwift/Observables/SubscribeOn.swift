//
//  SubscribeOn.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Wraps the source sequence in order to run its subscription and unsubscription logic on the specified
     scheduler.

     This operation is not commonly used.

     This only performs the side-effects of subscription and unsubscription on the specified scheduler.

     In order to invoke observer callbacks on a `scheduler`, use `observeOn`.

     - seealso: [subscribeOn operator on reactivex.io](http://reactivex.io/documentation/operators/subscribeon.html)

     - parameter scheduler: Scheduler to perform subscription and unsubscription actions on.
     - returns: The source sequence whose subscriptions and unsubscriptions happen on the specified scheduler.
     */
    public func subscribeOn(_ scheduler: ImmediateSchedulerType)
        -> Observable<E> {
            return SubscribeOn(source: self.asObservable(), scheduler: scheduler)
    }
}

final fileprivate class SubscribeOn<Element> : Producer<Element> {
    let source: Observable<Element>
    let scheduler: ImmediateSchedulerType
    
    init(source: Observable<Element>, scheduler: ImmediateSchedulerType) {
        self.source = source
        self.scheduler = scheduler
    }
    
    override func run(_ observer: @escaping (Event<Element>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)

        let subscription = SerialDisposable()
        let cancelSchedule = SingleAssignmentDisposable()

        subscription.disposable = cancelSchedule

        let disposeSchedule = scheduler.schedule(()) { (_) -> Disposable in
            let innerSubscription = self.source.subscribe { event in
                sink.forwardOn(event)

                if event.isStopEvent {
                    sink.dispose()
                }
            }
            subscription.disposable = ScheduledDisposable(scheduler: self.scheduler, disposable: innerSubscription)
            return Disposables.create()
        }

        cancelSchedule.setDisposable(disposeSchedule)

        return (sink: sink, subscription: subscription)
    }
}
