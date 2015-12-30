//
//  Observable+Bind.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

extension ObservableType {
    
    /**
    Creates new subscription and sends elements to observer.
    
    In this form it's equivalent to `subscribe` method, but it communicates intent better, and enables
    writing more consistent binding code.
    
    - parameter observer: Observer that receives events.
    - returns: Disposable object that can be used to unsubscribe the observer.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func bindTo<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.subscribe(observer)
    }

    /**
    Creates new subscription and sends elements to variable.

    In case error occurs in debug mode, `fatalError` will be raised.
    In case error occurs in release mode, `error` will be logged.

    - parameter variable: Target variable for sequence elements.
    - returns: Disposable object that can be used to unsubscribe the observer.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func bindTo(variable: Variable<E>) -> Disposable {
        return subscribe { e in
            switch e {
            case let .Next(element):
                variable.value = element
            case let .Error(error):
                let error = "Binding error to variable: \(error)"
            #if DEBUG
                rxFatalError(error)
            #else
                print(error)
            #endif
            case .Completed:
                break
            }
        }
    }
    
    /**
    Subscribes to observable sequence using custom binder function.
    
    - parameter binder: Function used to bind elements from `self`.
    - returns: Object representing subscription.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func bindTo<R>(binder: Self -> R) -> R {
        return binder(self)
    }

    /**
    Subscribes to observable sequence using custom binder function and final parameter passed to binder function
    after `self` is passed.
    
        public func bindTo<R1, R2>(binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
            return binder(self)(curriedArgument)
        }
    
    - parameter binder: Function used to bind elements from `self`.
    - parameter curriedArgument: Final argument passed to `binder` to finish binding process.
    - returns: Object representing subscription.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func bindTo<R1, R2>(binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
         return binder(self)(curriedArgument)
    }
    
    
    /**
    Subscribes an element handler to an observable sequence. 

    In case error occurs in debug mode, `fatalError` will be raised.
    In case error occurs in release mode, `error` will be logged.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.ud")
    public func bindNext(onNext: E -> Void) -> Disposable {
        return subscribe(onNext: onNext, onError: { error in
            let error = "Binding error to variable: \(error)"
            #if DEBUG
                rxFatalError(error)
            #else
                print(error)
            #endif
        })
    }
}