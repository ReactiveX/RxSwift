//
//  Observable+Concurrency.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// `observeSingleOn` assumes that observed sequence will have one element
// and in cases it has more than one element it will throw an exception.
//
// Most common use case for `observeSingleOn` would be to execute some work on background thread
// and return result to main thread.
//
// This is a performance gain considering general case.
public func observeSingleOn<E>
    (scheduler: ImmediateScheduler)
    -> Observable<E> -> Observable<E> {
    return { source in
        return ObserveSingleOn(source: source, scheduler: scheduler)
    }
}

public func observeOn<E>
    (scheduler: ImmediateScheduler)
    -> Observable<E> -> Observable<E> {
    return { source in
        if let scheduler = scheduler as? SerialDispatchQueueScheduler {
            return ObserveOnSerialDispatchQueue(source: source, scheduler: scheduler)
        }
        else {
            return ObserveOn(source: source, scheduler: scheduler)
        }
    }
}

public func subscribeOn<E>
    (scheduler: ImmediateScheduler)
    -> Observable<E> -> Observable<E> {
    return { source in
        return SubscribeOn(source: source, scheduler: scheduler)
    }
}