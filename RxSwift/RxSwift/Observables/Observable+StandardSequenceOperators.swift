//
//  Observable+StandardSequenceOperators.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// filter aka where

public func filterOrDie<E>
    (predicate: (E) -> RxResult<Bool>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return whereOrDie(predicate)(source)
    }
}

public func filter<E>
    (predicate: (E) -> Bool)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return `where`(predicate)(source)
    }
}

public func whereOrDie<E>
    (predicate: (E) -> RxResult<Bool>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Where(source: source, predicate: predicate)
    }
}

public func `where`<E>
    (predicate: (E) -> Bool)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Where(source: source, predicate: { success(predicate($0)) })
    }
}

// takeWhile

public func takeWhile<E>
    (predicate: (E) -> Bool)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return TakeWhile(source: source, predicate: predicate)
    }
}

public func takeWhile<E>
    (predicate: (E, Int) -> Bool)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return TakeWhile(source: source, predicate: predicate)
    }
}

// take

public func take<E>
    (count: Int)
    -> Observable<E> -> Observable<E> {
    return  { source in
        if count == 0 {
            return empty()
        }
        else {
            return TakeCount(source: source, count: count)
        }
    }
}

// skip

public func skip<E>
    (count: Int)
    -> Observable<E> -> Observable<E> {
    return  { source in
        return SkipCount(source: source, count: count)
    }
}

// map aka select

public func mapOrDie<E, R>
    (selector: E -> RxResult<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return selectOrDie(selector)(source)
    }
}

public func map<E, R>
    (selector: E -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return select(selector)(source)
    }
}

public func mapWithIndexOrDie<E, R>
    (selector: (E, Int) -> RxResult<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return selectWithIndexOrDie(selector)(source)
    }
}

public func mapWithIndex<E, R>
    (selector: (E, Int) -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return selectWithIndex(selector)(source)
    }
}

// select 

public func selectOrDie<E, R>
    (selector: (E) -> RxResult<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Map(source: source, selector: selector)
    }
}

public func select<E, R>
    (selector: (E) -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Map(source: source, selector: {success(selector($0)) })
    }
}

public func selectWithIndexOrDie<E, R>
    (selector: (E, Int) -> RxResult<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Map(source: source, selector: selector)
    }
}

public func selectWithIndex<E, R>
    (selector: (E, Int) -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Map(source: source, selector: {success(selector($0, $1)) })
    }
}

// flatMap

public func flatMap<E, R>
    (selector: (E) -> Observable<R>)
    -> Observable<E> -> Observable<R> {
    return { source in
        return FlatMap(source: source, selector: { success(selector($0)) })
    }
}

public func flatMapOrDie<E, R>
    (selector: (E) -> RxResult<Observable<R>>)
    -> Observable<E> -> Observable<R> {
    return { source in
        return FlatMap(source: source, selector: selector)
    }
}

public func flatMapWithIndex<E, R>
    (selector: (E, Int) -> Observable<R>)
    -> Observable<E> -> Observable<R> {
    return { source in
        return FlatMap(source: source, selector: { success(selector($0, $1)) })
    }
}

public func flatMapWithIndexOrDie<E, R>
    (selector: (E, Int) -> RxResult<Observable<R>>)
    -> Observable<E> -> Observable<R> {
    return { source in
        return FlatMap(source: source, selector: selector)
    }
}