//
//  Observable+StandardSequenceOperators.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// filter aka where

extension ObservableType {
    public func filter(predicate: (E) throws -> Bool)
        -> Observable<E> {
        return Filter(source: self.normalize(), predicate: predicate)
    }

    public func filter(predicate: (E) -> Bool)
        -> Observable<E> {
        return Filter(source: self.normalize(), predicate: predicate)
    }
}

// takeWhile

extension ObservableType {
    public func takeWhile(predicate: (E) -> Bool)
        -> Observable<E> {
        return TakeWhile(source: self.normalize(), predicate: predicate)
    }

    public func takeWhile(predicate: (E, Int) -> Bool)
        -> Observable<E> {
        return TakeWhile(source: self.normalize(), predicate: predicate)
    }
}

// take

extension ObservableType {
    public func take(count: Int)
        -> Observable<E> {
        if count == 0 {
            return empty()
        }
        else {
            return TakeCount(source: self.normalize(), count: count)
        }
    }
}
    
// skip

extension ObservableType {
    public func skip(count: Int)
        -> Observable<E> {
        return SkipCount(source: self.normalize(), count: count)
    }
}

// map aka select

extension ObservableType {
    public func map<R>(selector: E throws -> R)
        -> Observable<R> {
        return Map(source: self.normalize(), selector: selector)
    }

    public func map<R>(selector: E -> R)
        -> Observable<R> {
        return Map(source: self.normalize(), selector: selector)
    }

    public func mapWithIndex<R>(selector: (E, Int) throws -> R)
        -> Observable<R> {
        return Map(source: self.normalize(), selector: selector)
    }

    public func mapWithIndex<R>(selector: (E, Int) -> R)
        -> Observable<R> {
        return Map(source: self.normalize(), selector: selector)
    }
}
    
// flatMap

extension ObservableType {
    public func flatMap<R>(selector: (E) -> Observable<R>)
        -> Observable<R> {
        return FlatMap(source: self.normalize(), selector: selector)
    }

    public func flatMap<R>(selector: (E) throws -> Observable<R>)
        -> Observable<R> {
        return FlatMap(source: self.normalize(), selector: selector)
    }

    public func flatMapWithIndex<R>(selector: (E, Int) -> Observable<R>)
        -> Observable<R> {
        return FlatMap(source: self.normalize(), selector: selector)
    }

    public func flatMapWithIndex<R>(selector: (E, Int) throws -> Observable<R>)
        -> Observable<R> {
        return FlatMap(source: self.normalize(), selector: selector)
    }
}