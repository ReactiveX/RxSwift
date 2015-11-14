//
//  Observable+Time.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// MARK: throttle
extension ObservableType {
    
    /**
    Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.
 
    `throttle` and `debounce` are synonyms.
    
    - parameter dueTime: Throttling duration for each element.
    - parameter scheduler: Scheduler to run the throttle timers and send events on.
    - returns: The throttled sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func throttle<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
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
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func debounce<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return Throttle(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

// MARK: sample

extension ObservableType {
   
    /**
    Samples the source observable sequence using a samper observable sequence producing sampling ticks.
    
    Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.
    
    **In case there were no new elements between sampler ticks, no element is sent to the resulting sequence.**
    
    - parameter sampler: Sampling tick sequence.
    - returns: Sampled observable sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
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
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func sampleLatest<O: ObservableType>(sampler: O)
        -> Observable<E> {
        return Sample(source: self.asObservable(), sampler: sampler.asObservable(), onlyNew: false)
    }
}

// MARK: interval

/**
Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.

- parameter period: Period for producing the values in the resulting sequence.
- parameter scheduler: Scheduler to run the timer on.
- returns: An observable sequence that produces a value after each period.
*/
@warn_unused_result(message="http://git.io/rxs.uo")
public func interval<S: SchedulerType>(period: S.TimeInterval, _ scheduler: S)
    -> Observable<Int64> {
    return Timer(dueTime: period,
        period: period,
        scheduler: scheduler
    )
}

// MARK: timer

/**
Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

- parameter dueTime: Relative time at which to produce the first value.
- parameter period: Period to produce subsequent values.
- parameter scheduler: Scheduler to run timers on.
- returns: An observable sequence that produces a value after due time has elapsed and then each period.
*/
@warn_unused_result(message="http://git.io/rxs.uo")
public func timer<S: SchedulerType>(dueTime: S.TimeInterval, _ period: S.TimeInterval, _ scheduler: S)
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
@warn_unused_result(message="http://git.io/rxs.uo")
public func timer<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
    -> Observable<Int64> {
    return Timer(
        dueTime: dueTime,
        period: nil,
        scheduler: scheduler
    )
}

// MARK: take

extension ObservableType {

    /**
    Takes elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.
    
    - parameter duration: Duration for taking elements from the start of the sequence.
    - parameter scheduler: Scheduler to run the timer on.
    - returns: An observable sequence with the elements taken during the specified duration from the start of the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func take<S: SchedulerType>(duration: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return TakeTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}

// MARK: skip

extension ObservableType {
    
    /**
    Skips elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.
    
    - parameter duration: Duration for skipping elements from the start of the sequence.
    - parameter scheduler: Scheduler to run the timer on.
    - returns: An observable sequence with the elements skipped during the specified duration from the start of the source sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func skip<S: SchedulerType>(duration: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return SkipTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}


// MARK: delaySubscription

extension ObservableType {
    
    /**
    Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.
    
    - parameter dueTime: Relative time shift of the subscription.
    - parameter scheduler: Scheduler to run the subscription delay timer on.
    - returns: Time-shifted sequence.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func delaySubscription<S: SchedulerType>(dueTime: S.TimeInterval, _ scheduler: S)
        -> Observable<E> {
        return DelaySubscription(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

// MARK: buffer

extension ObservableType {

    /**
    Projects each element of an observable sequence into a buffer that's sent out when either it's full or a given amount of time has elapsed, using the specified scheduler to run timers.
    
    A useful real-world analogy of this overload is the behavior of a ferry leaving the dock when all seats are taken, or at the scheduled time of departure, whichever event occurs first.
    
    - parameter timeSpan: Maximum time length of a buffer.
    - parameter count: Maximum element count of a buffer.
    - parameter scheduler: Scheduler to run buffering timers on.
    - returns: An observable sequence of buffers.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func buffer<S: SchedulerType>(timeSpan timeSpan: S.TimeInterval, count: Int, scheduler: S)
        -> Observable<[E]> {
        return BufferTimeCount(source: self.asObservable(), timeSpan: timeSpan, count: count, scheduler: scheduler)
    }
}

// MARK: window

extension ObservableType {
    
    /**
     Projects each element of an observable sequence into a window that is completed when either it’s full or a given amount of time has elapsed.
          
     - parameter timeSpan: Maximum time length of a window.
     - parameter count: Maximum element count of a window.
     - parameter scheduler: Scheduler to run windowing timers on.
     - returns: An observable sequence of windows (instances of `Observable`).
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func window<S: SchedulerType>(timeSpan timeSpan: S.TimeInterval, count: Int, scheduler: S)
        -> Observable<Observable<E>> {
            return WindowTimeCount(source: self.asObservable(), timeSpan: timeSpan, count: count, scheduler: scheduler)
    }
}
