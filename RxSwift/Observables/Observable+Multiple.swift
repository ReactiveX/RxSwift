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
        return Switch(sources: self.asObservable())
    }
}

// concat

public func concat<O: ObservableType>(sources: [O])
    -> Observable<O.E> {
    return Concat(sources: LazySequence(sources).map { $0.asObservable() })
}

extension ObservableType where E : ObservableType {
    public var concat: Observable<E.E> {
        return self.merge(maxConcurrent: 1)
    }
}

// merge

extension ObservableType where E : ObservableType {
    public var merge: Observable<E.E> {
        return Merge(sources: self.asObservable(), maxConcurrent: 0)
    }

    public func merge(maxConcurrent maxConcurrent: Int)
        -> Observable<E.E> {
        return Merge(sources: self.asObservable(), maxConcurrent: maxConcurrent)
    }
}

// catch

extension ObservableType {
    public func catchErrorOrDie(handler: (ErrorType) throws -> Observable<E>)
        -> Observable<E> {
        return Catch(source: self.asObservable(), handler: handler)
    }
    
    public func catchError(handler: (ErrorType) -> Observable<E>)
        -> Observable<E> {
        return Catch(source: self.asObservable(), handler: handler)
    }

    // In case of error sends `errorElementValue` and completes sequence
    public func catchError(errorElementValue: E)
        -> Observable<E> {
        return Catch(source: self.asObservable(), handler: { _ in just(errorElementValue) })
    }
    
    // When error happens `error` will be forwarded as a next `Result<E>` value
    // and sequence will be completed.
    public var catchErrorToResult: Observable <RxResult<E>> {
        return CatchToResult(source: self.asObservable())
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
        return TakeUntil(source: self.asObservable(), other: other.asObservable())
    }
}

// amb

public func amb<O: ObservableType>
    (left: O, _ right: O)
    -> Observable<O.E> {
    return Amb(left: left.asObservable(), right: right.asObservable())
}

public func amb<O: ObservableType>
    (observables: AnySequence<O>)
    -> Observable<O.E> {
    return observables.reduce(never()) { a, o in
        return amb(a, o.asObservable())
    }
}
