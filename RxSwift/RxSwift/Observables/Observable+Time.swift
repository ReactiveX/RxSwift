//
//  Observable+Time.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// throttle

public func throttle<E, S: Scheduler>
    (dueTime: S.TimeInterval, scheduler: S)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Throttle(source: source, dueTime: dueTime, scheduler: scheduler)
    }
}

// sample

// If there isn't a new value in `source` sequence from the last sample time
// nothing will be forwarded.
public func sample<E, S>
    (sampler: Observable<S>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Sample(source: source, sampler: sampler, onlyNew: true)
    }
}

// On each sample latest element will always be forwarded.
public func sampleLatest<E, S>
    (sampler: Observable<S>)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Sample(source: source, sampler: sampler, onlyNew: false)
    }
}