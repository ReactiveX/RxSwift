//
//  Observable+Multiple.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// combineLatest

extension CollectionType where Generator.Element : ObservableType {
    public func combineLatest<R>(resultSelector: [Generator.Element.E] throws -> R) -> Observable<R> {
        return CombineLatestCollectionType(sources: self, resultSelector: resultSelector)
    }
}

// zip

extension CollectionType where Generator.Element : ObservableType {
    public func zip<R>(resultSelector: [Generator.Element.E] throws -> R) -> Observable<R> {
        return ZipCollectionType(sources: self, resultSelector: resultSelector)
    }
}

// switch

extension ObservableType where E : ObservableType {
    public func switchLatest() -> Observable<E.E> {
        return Switch(sources: self.asObservable())
    }
}

// concat

extension SequenceType where Generator.Element : ObservableType {
    public func concat()
        -> Observable<Generator.Element.E> {
        return Concat(sources: self)
    }
}

extension ObservableType where E : ObservableType {
    public func concat() -> Observable<E.E> {
        return self.merge(maxConcurrent: 1)
    }
}

// merge

extension ObservableType where E : ObservableType {
    public func merge() -> Observable<E.E> {
        return Merge(sources: self.asObservable(), maxConcurrent: 0)
    }

    public func merge(maxConcurrent maxConcurrent: Int)
        -> Observable<E.E> {
        return Merge(sources: self.asObservable(), maxConcurrent: maxConcurrent)
    }
}

// catch

extension ObservableType {
    public func catchError(handler: (ErrorType) throws -> Observable<E>)
        -> Observable<E> {
        return Catch(source: self.asObservable(), handler: handler)
    }

    // In case of error sends `errorElementValue` and completes sequence
    public func catchErrorResumeNext(errorElementValue: E)
        -> Observable<E> {
        return Catch(source: self.asObservable(), handler: { _ in just(errorElementValue) })
    }
    
    // When error happens `error` will be forwarded as a next `Result<E>` value
    // and sequence will be completed.
    public var catchErrorToResult: Observable <RxResult<E>> {
        return CatchToResult(source: self.asObservable())
    }
}

extension SequenceType where Generator.Element : ObservableType {
    public func catchError()
        -> Observable<Generator.Element.E> {
        return CatchSequence(sources: self)
    }
}

// takeUntil

extension ObservableType {
    public func takeUntil<O: ObservableType>(other: O)
        -> Observable<E> {
        return TakeUntil(source: self.asObservable(), other: other.asObservable())
    }
}

// amb

extension ObservableType {
    public func amb<O2: ObservableType where O2.E == E>
        (right: O2)
        -> Observable<E> {
        return Amb(left: self.asObservable(), right: right.asObservable())
    }
}

extension SequenceType where Generator.Element : ObservableType {
    public func amb()
        -> Observable<Generator.Element.E> {
        return self.reduce(never()) { a, o in
            return a.amb(o)
        }
    }
}
