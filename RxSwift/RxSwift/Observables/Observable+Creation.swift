//
//  Observable+Creation.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// create

public func create<E>(subscribe: (ObserverOf<E>) -> Disposable) -> Observable<E> {
    return AnonymousObservable(subscribe)
}

// empty

public func empty<E>() -> Observable<E> {
    return AnonymousObservable { observer in
        observer.on(.Completed)
        return DefaultDisposable()
    }
}

// never

public func never<E>() -> Observable<E> {
    return AnonymousObservable { observer in
        return DefaultDisposable()
    }
}

// return

public func returnElement<E>(value: E) -> Observable<E> {
    return AnonymousObservable { observer in
        observer.on(.Next(Box(value)))
        observer.on(.Completed)
        return DefaultDisposable()
    }
}

public func just<E>(value: E) -> Observable<E> {
    return returnElement(value)
}

public func returnElements<E>(values: E ...) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in values {
            observer.on(.Next(Box(element)))
        }
        
        observer.on(.Completed)
        return DefaultDisposable()
    }
}

// fail

public func failWith<E>(error: ErrorType) -> Observable<E> {
    return AnonymousObservable { observer in
        observer.on(.Error(error))
        return DefaultDisposable()
    }
}

// defer

public func deferOrDie<E>(observableFactory: () -> Result<Observable<E>>)
    -> Observable<E> {
    return Defer(observableFactory: observableFactory)
}

public func defer<E>(observableFactory: () -> Observable<E>)
    -> Observable<E> {
    return Defer(observableFactory: { success(observableFactory()) })
}