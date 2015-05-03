//
//  Observable+Multiple.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// switch

public func switchLatest<T>
    (sources: Observable<Observable<T>>)
    -> Observable<T> {
        
    // swift doesn't have co/contravariance
    return Switch(sources: sources)
}


// concat

public func concat<E>
    (sources: [Observable<E>])
    -> Observable<E> {
    return Concat(sources: sources)
}

public func concat<E>
    (sources: Observable<Observable<E>>)
    -> Observable<E> {
    return merge(maxConcurrent: 1)(sources)
}

// merge

public func merge<E>
    (sources: Observable<Observable<E>>)
    -> Observable<E> {
        return Merge(sources: sources, maxConcurrent: 0)
}

public func merge<E>
    (#maxConcurrent: Int)
    -> (Observable<Observable<E>> -> Observable<E>) {
    return  { sources in
        return Merge(sources: sources, maxConcurrent: maxConcurrent)
    }
}

// catch

public func catchOrDie<E>
    (handler: (ErrorType) -> Result<Observable<E>>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Catch(source: source, handler: handler)
    }
}

public func catch<E>
    (handler: (ErrorType) -> Observable<E>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Catch(source: source, handler: { success(handler($0)) })
    }
}

// In case of error, terminates sequence with `replaceErrorWith`.
public func catch<E>
    (replaceErrorWith: E)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Catch(source: source, handler: { _ in success(returnElement(replaceErrorWith)) })
    }
}

// When error happens `error` will be forwarded as a next `Result<E>` value
// and sequence will be completed.
public func catchToResult<E>
    (source: Observable<E>)
    -> Observable<Result<E>> {
    return CatchToResult(source: source)
}