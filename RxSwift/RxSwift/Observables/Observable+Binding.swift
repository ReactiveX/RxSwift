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

// refcount

public func refCount<E>
    (source: ConnectableObservableType<E>)
        -> Observable<E> {
    return RefCount(source: source)
}