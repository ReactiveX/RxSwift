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
    (predicate: (E) -> Result<Bool>)
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
    (predicate: (E) -> Result<Bool>)
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