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
        -> ObservableSource<Element, Completed, Error> {
        let source = self.asSource()
        return ObservableSource(run: .run { observer, cancel in
            let disposeEverything = SerialDisposable()
            let cancelSchedule = SingleAssignmentDisposable()
            
            disposeEverything.disposable = cancelSchedule
            
            let disposeSchedule = scheduler.schedule(()) { _ -> Disposable in
                let subscription = source.subscribe(observer)
                disposeEverything.disposable = ScheduledDisposable(scheduler: scheduler, disposable: subscription)
                return Disposables.create()
            }
            
            cancelSchedule.setDisposable(disposeSchedule)
            
            return disposeEverything
        })
    }
}
