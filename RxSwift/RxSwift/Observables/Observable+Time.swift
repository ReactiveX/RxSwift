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

public func debounce<E, S: Scheduler>
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

// interval

    // fallback {

public func interval<S: Scheduler>
    (period: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
        return Timer(dueTime: period,
            period: period,
            scheduler: scheduler,
            schedulePeriodic: abstractSchedulePeriodic(scheduler)
        )
}

    // }

    // periodic schedulers {

public func interval<S: PeriodicScheduler>
    (period: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
        return Timer(dueTime: period,
            period: period,
            scheduler: scheduler,
            schedulePeriodic: abstractSchedulePeriodic(scheduler)
        )
}

    // }

// timer

    // fallback {

public func timer<S: Scheduler>
    (#dueTime: S.TimeInterval, #period: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
        return Timer(
            dueTime: dueTime,
            period: period,
            scheduler: scheduler,
            schedulePeriodic: abstractSchedulePeriodic(scheduler)
        )
}

public func timer<S: Scheduler>
    (#dueTime: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
        return Timer(
            dueTime: dueTime,
            period: nil,
            scheduler: scheduler,
            schedulePeriodic: abstractSchedulePeriodic(scheduler)
        )
}

    // }

    // periodic schedulers {

public func timer<S: PeriodicScheduler>
    (#dueTime: S.TimeInterval, #period: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
        return Timer(
            dueTime: dueTime,
            period: period,
            scheduler: scheduler,
            schedulePeriodic: abstractSchedulePeriodic(scheduler)
        )
}

public func timer<S: PeriodicScheduler>
    (#dueTime: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
        return Timer(
            dueTime: dueTime,
            period: nil,
            scheduler: scheduler,
            schedulePeriodic: abstractSchedulePeriodic(scheduler)
        )
}

    // }

// take

public func take<E, S: Scheduler>
    (duration: S.TimeInterval, scheduler: S)
    -> Observable<E> -> Observable<E> {
    return { source in
        return TakeTime(source: source, duration: duration, scheduler: scheduler)
    }
}

// skip

public func skip<E, S: Scheduler>
    (duration: S.TimeInterval, scheduler: S)
    -> Observable<E> -> Observable<E> {
    return { source in
        return SkipTime(source: source, duration: duration, scheduler: scheduler)
    }
}


// delaySubscription

public func delaySubscription<E, S: Scheduler>
    (dueTime: S.TimeInterval, scheduler: S)
    -> Observable<E> -> Observable<E> {
    return { source in
        return DelaySubscription(source: source, dueTime: dueTime, scheduler: scheduler)
    }
}