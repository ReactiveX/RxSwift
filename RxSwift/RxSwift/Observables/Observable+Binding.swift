//
//  Observable+Binding.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// multicast

public func multicast<E, R>
    (subject: SubjectType<E, R>)
    -> (Observable<E> -> ConnectableObservableType<R>) {
    return { source in
        return ConnectableObservable(source: source, subject: subject)
    }
}

public func multicastOrDie<E, I, R>
    (
        subjectSelector: () -> RxResult<SubjectType<E, I>>,
        selector: (Observable<I>) -> RxResult<Observable<R>>
    )
    -> (Observable<E> -> Observable<R>) {
    
    return { source in
        return Multicast(
            source: source,
            subjectSelector: subjectSelector,
            selector: selector
        )
    }
}

public func multicast<E, I, R>
    (
        subjectSelector: () -> SubjectType<E, I>,
        selector: (Observable<I>) -> Observable<R>
    )
    -> (Observable<E> -> Observable<R>) {
        
        return { source in
            return Multicast(
                source: source,
                subjectSelector: { success(subjectSelector()) },
                selector: { success(selector($0)) }
            )
        }
}

// publish

public func publish<E>(source: Observable<E>)
    -> ConnectableObservableType<E> {
    return source >- multicast(PublishSubject())
}

// replay 

public func replay<E>
    (bufferSize: Int)
    -> (Observable<E> -> ConnectableObservableType<E>) {
    return { source in
        return multicast(ReplaySubject(bufferSize: bufferSize))(source)
    }
}

// refcount

public func refCount<E>
    (source: ConnectableObservableType<E>)
        -> Observable<E> {
    return RefCount(source: source)
}

// sharedWithCachedLastResult

// In Rx every subscription uses it's own set of resources.
// In case of UI, asynchronous operations are usually used to fetch data from server.
// In case data is fetched from server, stale data can be served first, and then updated with
// fresh data from server.

public func sharedWithCachedLastResult<E>(source: Observable<E>)
    -> Observable<E> {
    return source >- replay(1) >- refCount
}

// variable

// variable is synonym for `sharedWithCachedLastResult`
public func variable<E>(source: Observable<E>)
    -> Observable<E> {
    return source >- replay(1) >- refCount
}
