//
//  Observable+Extensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/14/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa

// taken from RxFeedback repo

extension ObservableType where Element == Any {
    /// Feedback loop
    public typealias Feedback<State, Event> = (ObservableSchedulerContext<State>) -> Observable<Event>
    public typealias FeedbackLoop = Feedback

    /**
     System simulation will be started upon subscription and stopped after subscription is disposed.

     System state is represented as a `State` parameter.
     Events are represented by `Event` parameter.

     - parameter initialState: Initial state of the system.
     - parameter accumulator: Calculates new system state from existing state and a transition event (system integrator, reducer).
     - parameter feedback: Feedback loops that produce events depending on current system state.
     - returns: Current state of the system.
     */
    public static func system<State, Event>(
        initialState: State,
        reduce: @escaping (State, Event) -> State,
        scheduler: ImmediateSchedulerType,
        scheduledFeedback: [Feedback<State, Event>]
        ) -> Observable<State> {
        return Observable<State>.deferred {
            let replaySubject = ReplaySubject<State>.create(bufferSize: 1)

            let asyncScheduler = scheduler.async

            let events: Observable<Event> = Observable.merge(scheduledFeedback.map { feedback in
                let state = ObservableSchedulerContext(source: replaySubject.asObservable(), scheduler: asyncScheduler)
                return feedback(state)
            })
                // This is protection from accidental ignoring of scheduler so
                // reentracy errors can be avoided
                .observe(on:CurrentThreadScheduler.instance)

            return events.scan(initialState, accumulator: reduce)
                .do(onNext: { output in
                    replaySubject.onNext(output)
                }, onSubscribed: {
                    replaySubject.onNext(initialState)
                })
                .subscribe(on: scheduler)
                .startWith(initialState)
                .observe(on:scheduler)
        }
    }

    public static func system<State, Event>(
        initialState: State,
        reduce: @escaping (State, Event) -> State,
        scheduler: ImmediateSchedulerType,
        scheduledFeedback: Feedback<State, Event>...
        ) -> Observable<State> {
        system(initialState: initialState, reduce: reduce, scheduler: scheduler, scheduledFeedback: scheduledFeedback)
    }
}

extension SharedSequenceConvertibleType where Element == Any, SharingStrategy == DriverSharingStrategy {
    /// Feedback loop
    public typealias Feedback<State, Event> = (Driver<State>) -> Signal<Event>

    /**
     System simulation will be started upon subscription and stopped after subscription is disposed.

     System state is represented as a `State` parameter.
     Events are represented by `Event` parameter.

     - parameter initialState: Initial state of the system.
     - parameter accumulator: Calculates new system state from existing state and a transition event (system integrator, reducer).
     - parameter feedback: Feedback loops that produce events depending on current system state.
     - returns: Current state of the system.
     */
    public static func system<State, Event>(
            initialState: State,
            reduce: @escaping (State, Event) -> State,
            feedback: [Feedback<State, Event>]
        ) -> Driver<State> {
        let observableFeedbacks: [(ObservableSchedulerContext<State>) -> Observable<Event>] = feedback.map { feedback in
            return { sharedSequence in
                return feedback(sharedSequence.source.asDriver(onErrorDriveWith: Driver<State>.empty()))
                    .asObservable()
            }
        }

        return Observable<Any>.system(
            initialState: initialState,
            reduce: reduce,
            scheduler: SharingStrategy.scheduler,
            scheduledFeedback: observableFeedbacks
            )
            .asDriver(onErrorDriveWith: .empty())
    }

    public static func system<State, Event>(
                initialState: State,
                reduce: @escaping (State, Event) -> State,
                feedback: Feedback<State, Event>...
        ) -> Driver<State> {
        system(initialState: initialState, reduce: reduce, feedback: feedback)
    }
}

extension ImmediateSchedulerType {
    var async: ImmediateSchedulerType {
        // This is a hack because of reentrancy. We need to make sure events are being sent async.
        // In case MainScheduler is being used MainScheduler.asyncInstance is used to make sure state is modified async.
        // If there is some unknown scheduler instance (like TestScheduler), just use it.
        return (self as? MainScheduler).map { _ in MainScheduler.asyncInstance } ?? self
    }
}


/// Tuple of observable sequence and corresponding scheduler context on which that observable
/// sequence receives elements.
public struct ObservableSchedulerContext<Element>: ObservableType {
    public typealias Element = Element

    /// Source observable sequence
    public let source: Observable<Element>

    /// Scheduler on which observable sequence receives elements
    public let scheduler: ImmediateSchedulerType

    /// Initializes self with source observable sequence and scheduler
    ///
    /// - parameter source: Source observable sequence.
    /// - parameter scheduler: Scheduler on which source observable sequence receives elements.
    public init(source: Observable<Element>, scheduler: ImmediateSchedulerType) {
        self.source = source
        self.scheduler = scheduler
    }

    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self.source.subscribe(observer)
    }
}
