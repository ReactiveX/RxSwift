//
//  Observable+Binding.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// multicast

extension ObservableType {
    public func multicast<R>(subject: SubjectType<E, R>)
        -> ConnectableObservableType<R> {
        return ConnectableObservable(source: self.normalize(), subject: subject)
    }

    public func multicast<I, R>(subjectSelector: () throws -> SubjectType<E, I>, selector: (Observable<I>) throws -> Observable<R>)
        -> Observable<R> {
        return Multicast(
            source: self.normalize(),
            subjectSelector: subjectSelector,
            selector: selector
        )
    }
}

// publish

extension ObservableType {
    public var publish: ConnectableObservableType<E> {
        return self.multicast(PublishSubject())
    }
}

// replay

extension ObservableType {
    public func replay(bufferSize: Int)
        -> ConnectableObservableType<E> {
        return self.multicast(ReplaySubject(bufferSize: bufferSize))
    }
}

// refcount

extension ConnectableObservableType {
    public var refCount: Observable<E> {
        return RefCount(source: self)
    }
}

// share 

extension ObservableType {
    public var share: Observable<E> {
        return self.publish.refCount
    }
}

// shareReplay

extension ObservableType {
    public func shareReplay(bufferSize: Int)
        -> Observable<E> {
        return self.replay(bufferSize).refCount
    }
}

// variable

extension ObservableType {
    // variable is alias for `shareReplay(1)`
    public var variable: Observable<E> {
        return self.replay(1).refCount
    }
}
