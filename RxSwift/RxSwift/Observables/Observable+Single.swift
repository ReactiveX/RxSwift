//
//  Observable+Single.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// as observable

public func asObservable<E>
    (source: Observable<E>) -> Observable<E> {
    if let asObservable = source as? AsObservable<E> {
        return asObservable.omega()
    }
    else {
        return AsObservable(source: source)
    }
}

// distinct until changed

public func distinctUntilChangedOrDie<E: Equatable>(source: Observable<E>)
    -> Observable<E> {
    return distinctUntilChangedOrDie({ success($0) }, { success($0 == $1) })(source)
}

public func distinctUntilChangedOrDie<E, K: Equatable>
    (keySelector: (E) -> Result<K>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return distinctUntilChangedOrDie(keySelector, { success($0 == $1) })(source)
    }
}

public func distinctUntilChangedOrDie<E>
    (comparer: (lhs: E, rhs: E) -> Result<Bool>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return distinctUntilChangedOrDie({ success($0) }, comparer)(source)
    }
}

public func distinctUntilChangedOrDie<E, K>
    (keySelector: (E) -> Result<K>, comparer: (lhs: K, rhs: K) -> Result<Bool>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return DistinctUntilChanged(source: source, selector: keySelector, comparer: comparer)
    }
}

public func distinctUntilChanged<E: Equatable>(source: Observable<E>)
    -> Observable<E> {
    return distinctUntilChanged({ $0 }, { ($0 == $1) })(source)
}

public func distinctUntilChanged<E, K: Equatable>
    (keySelector: (E) -> K)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return distinctUntilChanged(keySelector, { ($0 == $1) })(source)
    }
}

public func distinctUntilChanged<E>
    (comparer: (lhs: E, rhs: E) -> Bool)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return distinctUntilChanged({ ($0) }, comparer)(source)
    }
}

public func distinctUntilChanged<E, K>
    (keySelector: (E) -> K, comparer: (lhs: K, rhs: K) -> Bool)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return DistinctUntilChanged(source: source, selector: {success(keySelector($0)) }, comparer: { success(comparer(lhs: $0, rhs: $1))})
    }
}

// do

public func doOrDie<E>
    (eventHandler: (Event<E>) -> Result<Void>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Do(source: source, eventHandler: eventHandler)
    }
}

public func `do`<E>
    (eventHandler: (Event<E>) -> Void)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Do(source: source, eventHandler: { success(eventHandler($0)) })
    }
}

// doOnNext

public func doOnNext<E>
    (actionOnNext: E -> Void)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return source >- `do` { event in
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                actionOnNext(value)
            default:
                break
            }
        }
    }
}

// map aka select

public func mapOrDie<E, R>
    (selector: E -> Result<R>)
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
    (selector: (E, Int) -> Result<R>)
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
    (selector: (E) -> Result<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Select(source: source, selector: selector)
    }
}

public func select<E, R>
    (selector: (E) -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Select(source: source, selector: {success(selector($0)) })
    }
}

public func selectWithIndexOrDie<E, R>
    (selector: (E, Int) -> Result<R>)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Select(source: source, selector: selector)
    }
}

public func selectWithIndex<E, R>
    (selector: (E, Int) -> R)
    -> (Observable<E> -> Observable<R>) {
    return { source in
        return Select(source: source, selector: {success(selector($0, $1)) })
    }
}

// Prefixes observable sequence with `firstElement` element.
// The same functionality could be achieved using `concat([returnElement(prefix), source])`,
// but this is significantly more efficient implementation.
public func startWith<E>
    (firstElement: E)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return StartWith(source: source, element: firstElement)
    }
}

