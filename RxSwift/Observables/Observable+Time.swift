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
    
    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
 
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - parameter scheduler: Scheduler to run the throttle timers and send events on.
    - returns: The throttled sequence.
    */
    public func throttle<S: Scheduler>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return Throttle(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }

    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
    
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - parameter scheduler: Scheduler to run the throttle timers and send events on.
    - returns: The throttled sequence.
    */
    public func debounce<S: Scheduler>(dueTime: S.TimeInterval, scheduler: S)
        -> Observable<E> {
        return Throttle(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

// sample

extension ObservableType {
   
    /**
    Samples the source observable sequence using a samper observable sequence producing sampling ticks.
    
    Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.
    
    **In case there were no new elements between sampler ticks, no element is sent to the resulting sequence.**
    
    - parameter sampler: Sampling tick sequence.
    - returns: Sampled observable sequence.
    */
    public func sample<O: ObservableType>(sampler: O)
        -> Observable<E> {
        return Sample(source: self.asObservable(), sampler: sampler.asObservable(), onlyNew: true)
    }

    /**
    Samples the source observable sequence using a samper observable sequence producing sampling ticks.
    
    Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.
    
    **In case there were no new elements between sampler ticks, last produced element is always sent to the resulting sequence.**
    
    - parameter sampler: Sampling tick sequence.
    - returns: Sampled observable sequence.
    */
    public func sampleLatest<O: ObservableType>(sampler: O)
        -> Observable<E> {
        return Sample(source: self.asObservable(), sampler: sampler.asObservable(), onlyNew: false)
    }
}

// interval

/**
Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.

- parameter period: Period for producing the values in the resulting sequence.
- parameter scheduler: Scheduler to run the timer on.
- returns: An observable sequence that produces a value after each period.
*/
public func interval<S: Scheduler>(period: S.TimeInterval, _ scheduler: S)
    -> Observable<Int64> {
    return Timer(dueTime: period,
        period: period,
        scheduler: scheduler
    )
}

// timer

/**
Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

- parameter dueTime: Relative time at which to produce the first value.
- parameter period: Period to produce subsequent values.
- parameter scheduler: Scheduler to run timers on.
- returns: An observable sequence that produces a value after due time has elapsed and then each period.
*/
public func timer<S: Scheduler>(dueTime: S.TimeInterval, _ period: S.TimeInterval, _ scheduler: S)
    -> Observable<Int64> {
    return Timer(
        dueTime: dueTime,
        period: period,
        scheduler: scheduler
    )
}

/**
Returns an observable sequence that produces a single value at the specified absolute due time, using the specified scheduler to run the timer.

- parameter dueTime: Time interval after which to produce the value.
- parameter scheduler: Scheduler to run the timer on.
- returns: An observable sequence that produces a value at due time.
*/
public func timer<S: Scheduler>(dueTime: S.TimeInterval, _ scheduler: S)
    -> Observable<Int64> {
    return Timer(
        dueTime: dueTime,
        period: nil,
        scheduler: scheduler
    )
}

// take

extension ObservableType {

    /**
    Takes elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.
    
    - parameter duration: Duration for taking elements from the start of the sequence.
    - parameter scheduler: Scheduler to run the timer on.
    - returns: An observable sequence with the elements taken during the specified duration from the start of the source sequence.
    */
    public func take<S: Scheduler>(duration: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return TakeTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}

// skip

extension ObservableType {
    
    /**
    Skips elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.
    
    - parameter duration: Duration for skipping elements from the start of the sequence.
    - parameter scheduler: Scheduler to run the timer on.
    - returns: An observable sequence with the elements skipped during the specified duration from the start of the source sequence.
    */
    public func skip<S: Scheduler>(duration: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return SkipTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}


// delaySubscription

extension ObservableType {
    
    /**
    Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.
    
    - parameter dueTime: Relative time shift of the subscription.
    - parameter scheduler: Scheduler to run the subscription delay timer on.
    - returns: Time-shifted sequence.
    */
    public func delaySubscription<S: Scheduler>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return DelaySubscription(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}