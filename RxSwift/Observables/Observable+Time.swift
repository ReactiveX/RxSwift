//
//  Observable+Time.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// throttle
extension ObservableType {
    public func throttle<S: Scheduler>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return Throttle(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }

    public func debounce<S: Scheduler>(dueTime: S.TimeInterval, scheduler: S)
        -> Observable<E> {
        return Throttle(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

// sample

extension ObservableType {
    // If there isn't a new value in `source` sequence from the last sample time
    // nothing will be forwarded.
    public func sample<S>(sampler: Observable<S>)
        -> Observable<E> {
        return Sample(source: self.asObservable(), sampler: sampler, onlyNew: true)
    }

    // On each sample latest element will always be forwarded.
    public func sampleLatest<S>(sampler: Observable<S>)
        -> Observable<E> {
        return Sample(source: self.asObservable(), sampler: sampler, onlyNew: false)
    }
}

// interval



    // fallback {

public func interval<S: Scheduler>(period: S.TimeInterval, _ scheduler: S)
    -> Observable<Int64> {
    return Timer(dueTime: period,
        period: period,
        scheduler: scheduler,
        schedulePeriodic: abstractSchedulePeriodic(scheduler)
    )
}

    // }

    // periodic schedulers {

public func interval<S: PeriodicScheduler>(period: S.TimeInterval, _ scheduler: S)
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

public func timer<S: Scheduler>(dueTime: S.TimeInterval, _ period: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
    return Timer(
        dueTime: dueTime,
        period: period,
        scheduler: scheduler,
        schedulePeriodic: abstractSchedulePeriodic(scheduler)
    )
}

public func timer<S: Scheduler>(dueTime: S.TimeInterval, scheduler: S)
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

public func timer<S: PeriodicScheduler>(dueTime: S.TimeInterval, _ period: S.TimeInterval, scheduler: S)
    -> Observable<Int64> {
    return Timer(
        dueTime: dueTime,
        period: period,
        scheduler: scheduler,
        schedulePeriodic: abstractSchedulePeriodic(scheduler)
    )
}

public func timer<S: PeriodicScheduler>(dueTime: S.TimeInterval, scheduler: S)
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

extension ObservableType {
    public func take<S: Scheduler>(duration: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return TakeTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}

// skip

extension ObservableType {
    public func skip<S: Scheduler>(duration: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return SkipTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}


// delaySubscription

extension ObservableType {
    public func delaySubscription<S: Scheduler>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return DelaySubscription(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}