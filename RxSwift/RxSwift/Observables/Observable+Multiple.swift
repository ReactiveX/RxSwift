//
//  Observable+Multiple.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// switch

extension ObservableType where E : ObservableType {
    public var switchLatest: Observable<E.E> {
        // swift doesn't have co/contravariance
        return Switch(sources: self.normalize())
    }
}

// concat

public func concat<O: ObservableType>(sources: [O])
    -> Observable<O.E> {
    return Concat(sources: LazySequence(sources).map { $0.normalize() })
}

extension ObservableType where E : ObservableType {
    public var concat: Observable<E.E> {
        return self.merge(maxConcurrent: 1)
    }
}

// merge

extension ObservableType where E : ObservableType {
    public var merge: Observable<E.E> {
        return Merge(sources: self.normalize(), maxConcurrent: 0)
    }

    public func merge(maxConcurrent maxConcurrent: Int)
        -> Observable<E.E> {
        return Merge(sources: self.normalize(), maxConcurrent: maxConcurrent)
    }
}

// catch

extension ObservableType {
    public func catchErrorOrDie(handler: (ErrorType) -> RxResult<Observable<E>>)
        -> Observable<E> {
        return Catch(source: self.normalize(), handler: handler)
    }
    
    public func catchError(handler: (ErrorType) -> Observable<E>)
        -> Observable<E> {
        return Catch(source: self.normalize(), handler: { success(handler($0)) })
    }

    // In case of error, terminates sequence with `replaceErrorWith`.
    public func catchError(replaceErrorWith: E)
        -> Observable<E> {
        return Catch(source: self.normalize(), handler: { _ in success(just(replaceErrorWith)) })
    }
    
    // When error happens `error` will be forwarded as a next `Result<E>` value
    // and sequence will be completed.
    public var catchErrorToResult: Observable <RxResult<E>> {
        return CatchToResult(source: self.normalize())
    }
}

public func catchError<E>(sources: AnySequence<Observable<E>>)
    -> Observable<E> {
    // just wrapping it in sequence of for now
    return CatchSequence(sources: sources)
}

// takeUntil

extension ObservableType {
    public func takeUntil<O: ObservableType>(other: O)
        -> Observable<E> {
        return TakeUntil(source: self.normalize(), other: other.normalize())
    }
}

// amb

public func amb<O: ObservableType>
    (left: O, _ right: O)
    -> Observable<O.E> {
    return Amb(left: left.normalize(), right: right.normalize())
}

public func amb<O: ObservableType>
    (observables: AnySequence<O>)
    -> Observable<O.E> {
    return observables.reduce(never()) { a, o in
        return amb(a, o.normalize())
    }
}
