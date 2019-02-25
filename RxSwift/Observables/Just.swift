//
//  Just.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType where Completed == () {
    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element) -> ObservableSource<Element, Completed, Error> {
        return ObservableSource(run: .just(element, ()))
    }

    /**
     Returns an observable sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)

     - parameter element: Single element in the resulting observable sequence.
     - parameter scheduler: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    public static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> ObservableSource<Element, Completed, Error> {
        return ObservableSource(run: .run { observer, cancel in
            return scheduler.schedule(element) { element in
                observer(.next(element))
                return scheduler.schedule(()) { _ in
                    observer(.completed(()))
                    cancel.dispose()
                    return Disposables.create()
                }
            }
        })
    }
}
