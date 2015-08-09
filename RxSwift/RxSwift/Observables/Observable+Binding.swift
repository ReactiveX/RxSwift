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

    public func multicastOrDie<I, R>(
            subjectSelector: () -> RxResult<SubjectType<E, I>>,
            selector: (Observable<I>) -> RxResult<Observable<R>>
        )
        -> Observable<R> {
        return Multicast(
            source: self.normalize(),
            subjectSelector: subjectSelector,
            selector: selector
        )
    }

    public func multicast<I, R>
        (
            subjectSelector: () -> SubjectType<E, I>,
            selector: (Observable<I>) -> Observable<R>
        )
        -> Observable<R> {
            
        return Multicast(
            source: self.normalize(),
            subjectSelector: { success(subjectSelector()) },
            selector: { success(selector($0)) }
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
