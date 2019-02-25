//
//  Optional.swift
//  RxSwift
//
//  Created by tarunon on 2016/12/13.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Converts a optional to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter optional: Optional element in the resulting observable sequence.
     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
    public static func from(optional: Element?) -> ObservableSource<Element, (), Error> {
        return ObservableSource(run: .run { observer, cancel in
            if let element = optional {
                observer(.next(element))
            }
            observer(.completed(()))
            return Disposables.create()
        })
    }

    /**
     Converts a optional to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter optional: Optional element in the resulting observable sequence.
     - parameter scheduler: Scheduler to send the optional element on.
     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
    public static func from(optional: Element?, scheduler: ImmediateSchedulerType) -> ObservableSource<Element, (), Error> {
        return ObservableSource(run: .run { observer, cancel in
             let subscription = scheduler.schedule(optional) { (optional: Element?) -> Disposable in
                if let next = optional {
                    observer(.next(next))
                    return scheduler.schedule(()) { _ in
                        observer(.completed(()))
                        cancel.dispose()
                        return Disposables.create()
                    }
                } else {
                    observer(.completed(()))
                    cancel.dispose()
                    return Disposables.create()
                }
            }
            
            return subscription
        })
    }
}
