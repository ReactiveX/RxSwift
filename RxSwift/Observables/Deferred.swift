//
//  Deferred.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType where Error == Swift.Error {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    public static func deferred(_ observableFactory: @escaping () throws -> ObservableSource<Element, Completed, Error>)
        -> ObservableSource<Element, Completed, Error> {
        return ObservableSource(run: .run { observer, cancel in
            do {
                let result = try observableFactory()
                let subscription = result.subscribe(observer)
                return subscription
            }
            catch let error {
                observer(.error(error))
                cancel.dispose()
                return Disposables.create()
            }
        })
    }
}

extension ObservableType {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.
     
     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)
     
     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    public static func deferred(_ observableFactory: @escaping () -> ObservableSource<Element, Completed, Error>)
        -> ObservableSource<Element, Completed, Error> {
        return ObservableSource(run: .run { observer, cancel in
            let result = observableFactory()
            let subscription = result.subscribe(observer)
            return subscription
        })
    }
}
