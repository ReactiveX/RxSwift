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
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

// never

public func never<E>() -> Observable<E> {
    return AnonymousObservable { observer in
        return NopDisposable.instance
    }
}

// return

public func just<E>(value: E) -> Observable<E> {
    return AnonymousObservable { observer in
        sendNext(observer, value)
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

public func sequenceOf<E>(values: E ...) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in values {
            sendNext(observer, element)
        }
        
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

public func from<E, S where S: SequenceType, S.Generator.Element == E>(sequence: S) -> Observable<E> {
    return AnonymousObservable { observer in
        for element in sequence {
            sendNext(observer, element)
        }
        
        sendCompleted(observer)
        return NopDisposable.instance
    }
}

// fail

public func failWith<E>(error: ErrorType) -> Observable<E> {
    return AnonymousObservable { observer in
        sendError(observer, error)
        return NopDisposable.instance
    }
}

// defer

public func deferred<E>(observableFactory: () throws -> Observable<E>)
    -> Observable<E> {
    return Deferred(observableFactory: observableFactory)
}