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

// `observeOn` operator observes elements on `scheduler`.
//
// That means that any further processing operator, like `map`, `filer` will be executed
// on that `scheduler`.
//
// If is optimized internally for two cases.
//
// More performant case is when `DispatchQueueScheduler` is passed.
// Because of serial nature of that scheduler, operator can optimize observing process.
//
// One of the typical use cases is observing elements on main thread, and `MainScheduler` is
// subtype of `DispatchQueueScheduler`, so it should have really low overhead.
//
// On the other hand, if some concurrent background scheduler is passed, 
// the typical use case for that would be getting long running work of main thread 
// and onto background thread.
//
// In that case, the workload will probably be intensive, so using unoptimized version
// shouldn't cause problems.
//
// This could be further optimized in future if needed.
public func observeOn<E>
    (scheduler: ImmediateScheduler)
    -> Observable<E> -> Observable<E> {
    return { source in
        if let scheduler = scheduler as? SerialDispatchQueueScheduler {
            return ObserveOnDispatchQueue(source: source, scheduler: scheduler)
        }
        else {
            return source
                >- map { e in
                    returnElement(e) >- observeSingleOn(scheduler)
                }
                >- concat
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