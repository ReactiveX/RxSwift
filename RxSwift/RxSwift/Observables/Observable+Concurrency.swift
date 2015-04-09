//
//  Observable+Concurrency.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Currently only simple observing is implemented.
//
// On client devices most common use case for observeOn would be to execute some work on background thread
// or return result to main thread.
//
// `observeSingleOn` is optimized for that specific purpose. It assumes that sequence will have one element
// and in cases it has more then one element it will throw an exception.
//
// This is a huge performance win considering most general case.
//
// General slower version of `observeOn` will not be implemented until needed.
//
// Even though it looks like naive implementation of general `observeOn` using simple `schedule`
// for each event will work, this is not the case.

public func observeSingleOn<E>
    (scheduler: ImmediateScheduler)
    -> ((Observable<E>) -> Observable<E>) {
    return { source in
        return ObserveSingleOn(source: source, scheduler: scheduler)
    }
}
