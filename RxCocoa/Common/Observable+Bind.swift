//
//  Observable+Bind.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 8/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


import RxSwift

extension ObservableType {
    /**
     Creates new subscription and sends elements to bindable.

     - parameter to: Bindable that receives events.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind<B: Bindable>(to bindable: B) -> Disposable where B.T == E {
        return self.subscribe { bindable.handle($0) }
    }

    /**
     Creates new subscription and sends elements to bindable.

     - parameter to: Bindable that receives events.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind<B: Bindable>(to bindable: B) -> Disposable where B.T == E? {
        return self.map { $0 }.subscribe { bindable.handle($0) }
    }
    
    /**
    Subscribes to observable sequence using custom binder function.
    
    - parameter to: Function used to bind elements from `self`.
    - returns: Object representing subscription.
    */
    public func bind<R>(to binder: (Self) -> R) -> R {
        return binder(self)
    }

    /**
    Subscribes to observable sequence using custom binder function and final parameter passed to binder function
    after `self` is passed.
    
        public func bind<R1, R2>(to binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
            return binder(self)(curriedArgument)
        }
    
    - parameter to: Function used to bind elements from `self`.
    - parameter curriedArgument: Final argument passed to `binder` to finish binding process.
    - returns: Object representing subscription.
    */
    public func bind<R1, R2>(to binder: (Self) -> (R1) -> R2, curriedArgument: R1) -> R2 {
         return binder(self)(curriedArgument)
    }
    
    
    /**
    Subscribes an element handler to an observable sequence. 

    In case error occurs in debug mode, `fatalError` will be raised.
    In case error occurs in release mode, `error` will be logged.
    
    - parameter onNext: Action to invoke for each element in the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    public func bind(onNext: @escaping (E) -> Void) -> Disposable {
        return subscribe(onNext: onNext, onError: { error in
            rxFatalErrorInDebug("Binding error: \(error)")
        })
    }
}

extension PublishRelay: Bindable {
    public typealias T = Element
    /**
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     */
    public func handle(_ event: Event<T>) {
        switch event {
        case let .next(element):
            self.accept(element)
        case let .error(error):
            rxFatalErrorInDebug("Binding error to publish relay: \(error)")
        case .completed:
            break
        }
    }
}

extension BehaviorRelay: Bindable {
    public typealias T = Element
    /**
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     */
    public func handle(_ event: Event<T>) {
        switch event {
        case let .next(element):
            self.accept(element)
        case let .error(error):
            rxFatalErrorInDebug("Binding error to behavior relay: \(error)")
        case .completed:
            break
        }
    }
}
