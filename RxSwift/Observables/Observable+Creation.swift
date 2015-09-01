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
    return Empty<E>()
}

// never

public func never<E>() -> Observable<E> {
    return Never()
}

// return

public func just<E>(element: E) -> Observable<E> {
    return Just(element: element)
}

public func sequenceOf<E>(elements: E ...) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in elements {
            observer.on(.Next(element))
        }
        
        observer.on(.Completed)
        return NopDisposable.instance
    }
}

public func from<E, S where S: SequenceType, S.Generator.Element == E>(sequence: S) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in sequence {
            observer.on(.Next(element))
        }
        
        observer.on(.Completed)
        return NopDisposable.instance
    }
}

// fail

public func failWith<E>(error: ErrorType) -> Observable<E> {
    return FailWith(error: error)
}

// defer

public func deferred<E>(observableFactory: () throws -> Observable<E>)
    -> Observable<E> {
    return Deferred(observableFactory: observableFactory)
}