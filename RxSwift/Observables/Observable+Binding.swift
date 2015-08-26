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
    public func multicast<S: SubjectType where S.SubjectObserverType.E == E>(subject: S)
        -> ConnectableObservable<S> {
        return ConnectableObservable(source: self.asObservable(), subject: subject)
    }

    public func multicast<S: SubjectType, R where S.SubjectObserverType.E == E>(subjectSelector: () throws -> S, selector: (Observable<S.E>) throws -> Observable<R>)
        -> Observable<R> {
        return Multicast(
            source: self.asObservable(),
            subjectSelector: subjectSelector,
            selector: selector
        )
    }
}

// publish

extension ObservableType {
    public func publish() -> ConnectableObservable<PublishSubject<E>> {
        return self.multicast(PublishSubject())
    }
}

// replay

extension ObservableType {
    public func replay(bufferSize: Int)
        -> ConnectableObservable<ReplaySubject<E>> {
        return self.multicast(ReplaySubject.create(bufferSize: bufferSize))
    }
}

// refcount

extension ConnectableObservableType {
    public func refCount() -> Observable<E> {
        return RefCount(source: self)
    }
}

// share 

extension ObservableType {
    public func share() -> Observable<E> {
        return self.publish().refCount()
    }
}

// shareReplay

extension ObservableType {
    public func shareReplay(bufferSize: Int)
        -> Observable<E> {
        return self.replay(bufferSize).refCount()
    }
}