//
//  Observable+Binding.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// MARK: multicast

extension ObservableType {
    
    /**
    Multicasts the source sequence notifications through the specified subject to the resulting connectable observable. 
    
    Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.
    
    For specializations with fixed subject types, see `publish` and `replay`.
    
    - parameter subject: Subject to push source elements into.
    - returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func multicast<S: SubjectType where S.SubjectObserverType.E == E>(subject: S)
        -> ConnectableObservable<S> {
        return ConnectableObservable(source: self.asObservable(), subject: subject)
    }

    /**
    Multicasts the source sequence notifications through an instantiated subject into all uses of the sequence within a selector function. 
    
    Each subscription to the resulting sequence causes a separate multicast invocation, exposing the sequence resulting from the selector function's invocation.

    For specializations with fixed subject types, see `publish` and `replay`.
    
    - parameter subjectSelector: Factory function to create an intermediate subject through which the source sequence's elements will be multicast to the selector function.
    - parameter selector: Selector function which can use the multicasted source sequence subject to the policies enforced by the created subject.
    - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence within a selector function.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func multicast<S: SubjectType, R where S.SubjectObserverType.E == E>(subjectSelector: () throws -> S, selector: (Observable<S.E>) throws -> Observable<R>)
        -> Observable<R> {
        return Multicast(
            source: self.asObservable(),
            subjectSelector: subjectSelector,
            selector: selector
        )
    }
}

// MARK: publish

extension ObservableType {
    
    /**
    Returns a connectable observable sequence that shares a single subscription to the underlying sequence. 
    
    This operator is a specialization of `multicast` using a `PublishSubject`.
    
    - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func publish() -> ConnectableObservable<PublishSubject<E>> {
        return self.multicast(PublishSubject())
    }
}

// MARK: replay

extension ObservableType {
    
    /**
    Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying bufferSize elements.
    
    This operator is a specialization of `multicast` using a `ReplaySubject`.
    
    - parameter bufferSize: Maximum element count of the replay buffer.
    - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func replay(bufferSize: Int)
        -> ConnectableObservable<ReplaySubject<E>> {
        return self.multicast(ReplaySubject.create(bufferSize: bufferSize))
    }
}

// MARK: refcount

extension ConnectableObservableType {
    
    /**
    Returns an observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
    
    - returns: An observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func refCount() -> Observable<E> {
        return RefCount(source: self)
    }
}

// MARK: share

extension ObservableType {
    
    /**
    Returns an observable sequence that shares a single subscription to the underlying sequence.
    
    This operator is a specialization of publish which creates a subscription when the number of observers goes from zero to one, then shares that subscription with all subsequent observers until the number of observers returns to zero, at which point the subscription is disposed.
    
    - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func share() -> Observable<E> {
        return self.publish().refCount()
    }
}

// MARK: shareReplay

extension ObservableType {
    
    /**
    Returns an observable sequence that shares a single subscription to the underlying sequence replaying notifications subject to a maximum time length for the replay buffer.
    
    This operator is a specialization of replay which creates a subscription when the number of observers goes from zero to one, then shares that subscription with all subsequent observers until the number of observers returns to zero, at which point the subscription is disposed.
    
    - parameter bufferSize: Maximum element count of the replay buffer.
    - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func shareReplay(bufferSize: Int)
        -> Observable<E> {
        if bufferSize == 1 {
            return ShareReplay1(source: self.asObservable())
        }
        else {
            return self.replay(bufferSize).refCount()
        }
    }
}