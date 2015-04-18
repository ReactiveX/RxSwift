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
        subjectSelector: () -> Result<SubjectType<E, I>>,
        selector: (Observable<I>) -> Result<Observable<R>>
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