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