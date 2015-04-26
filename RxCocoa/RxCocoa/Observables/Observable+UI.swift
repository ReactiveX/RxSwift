//
//  Observable+UI.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

// In Rx every subscription uses it's own set of resources.
// In case of UI, asynchronous operations are usually used to fetch data from server.
// In case data is fetched from server, stale data can be server first, and then updated with 
// fresh data from server.

public func sharedWithCachedLastResult<E>(source: Observable<E>)
    -> Observable<E> {
    return source >- replay(1) >- refCount
}

// variable is synonym for `sharedWithCachedLastResult`
public func variable<E>(source: Observable<E>)
    -> Observable<E> {
    return source >- replay(1) >- refCount
}

// prefix with

// Prefixes observable sequence with `prefix` element.
// The same functionality could be achieved using `concat([returnElement(prefix), source])`,
// but this is significantly more efficient implementation.
public func prefixWith<E>
    (prefix: E)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Prefix(source: source, element: prefix)
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