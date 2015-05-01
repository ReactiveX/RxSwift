//
//  Observable+Subscription.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public func subscribe<E>
    (on: (event: Event<E>) -> Void)
    (source: Observable<E>) -> Disposable {
    let observer: ObserverOf<E> = ObserverOf(AnonymousObserver { e in
        on(event: e)
    })
    return source.subscribe(observer)
}

public func subscribeNext<E>
    (onNext: (E) -> Void)
    (source: Observable<E>) -> Disposable {
    let observer: ObserverOf<E> = ObserverOf(AnonymousObserver { e in
        switch e {
        case .Next(let boxedValue):
            onNext(boxedValue.value)
        default:
            break
        }
    })
    return source.subscribe(observer)
}