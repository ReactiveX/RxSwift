//
//  Observable+Creation.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// create

public func create<E>(subscribe: (ObserverOf<E>) ->  Result<Disposable>) -> Observable<E> {
    return AnonymousObservable(subscribe)
}

// empty

public func empty<E>() -> Observable<E> {
    return AnonymousObservable { observer in
        let result : Result<Void> = observer.on(.Completed)
        return result >>> { (DefaultDisposable()) }
    }
}

// never

public func never<E>() -> Observable<E> {
    return AnonymousObservable { observer in
        return success(DefaultDisposable())
    }
}

// return

public func returnElement<E>(value: E) -> Observable<E> {
    return AnonymousObservable { observer in
        return observer.on(.Next(Box(value))) >>> { observer.on(.Completed) } >>> { (DefaultDisposable()) }
    }
}

public func returnElement<E>(values: E ...) -> Observable<E> {
    return AnonymousObservable { observer in
        var result = SuccessResult
        
        for element in values {
            result = result >>> { observer.on(.Next(Box(element))) }
        }
        
        return (result >>> { observer.on(.Completed) }) >>> { (DefaultDisposable()) }
    }
}