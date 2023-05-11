//
//  TestScheduler.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// Virtual time scheduler used for testing applications and libraries built using RxSwift.
public class TestScheduler : VirtualTimeScheduler<TestSchedulerVirtualTimeConverter> {
    /// Default values of scheduler times.
    public struct Defaults {
        /// Default absolute time when to create tested observable sequence.
        public static let created = 100
        /// Default absolute time when to subscribe to tested observable sequence.
        public static let subscribed = 200
        /// Default absolute time when to dispose subscription to tested observable sequence.
        public static let disposed = 1000
    }

    private let simulateProcessingDelay: Bool

    /**
     Creates a new test scheduler.
     
     - parameter initialClock: Initial value for the clock.
     - parameter resolution: Real time [TimeInterval] = ticks * resolution 
     - parameter simulateProcessingDelay: When true, if something is scheduled right `now`, 
        it will be scheduled to `now + 1` in virtual time.
    */
    public init(initialClock: TestTime, resolution: Double = 1.0, simulateProcessingDelay: Bool = true) {
        self.simulateProcessingDelay = simulateProcessingDelay
        super.init(initialClock: initialClock, converter: TestSchedulerVirtualTimeConverter(resolution: resolution))
    }

    /**
    Creates a hot observable using the specified timestamped events.
     
    - parameter events: Events to surface through the created sequence at their specified absolute virtual times.
    - returns: Hot observable sequence that can be used to assert the timing of subscriptions and events.
    */
    public func createHotObservable<Element>(_ events: [Recorded<Event<Element>>]) -> TestableObservable<Element> {
        HotObservable(testScheduler: self as AnyObject as! TestScheduler, recordedEvents: events)
    }

    /**
    Creates a cold observable using the specified timestamped events.
     
     - parameter events: Events to surface through the created sequence at their specified virtual time offsets from the sequence subscription time.
     - returns: Cold observable sequence that can be used to assert the timing of subscriptions and events.
    */
    public func createColdObservable<Element>(_ events: [Recorded<Event<Element>>]) -> TestableObservable<Element> {
        ColdObservable(testScheduler: self as AnyObject as! TestScheduler, recordedEvents: events)
    }

    /**
    Creates an observer that records received events and timestamps those.
    
     - parameter type: Optional type hint of the observed sequence elements.
     - returns: Observer that can be used to assert the timing of events.
    */
    public func createObserver<Element>(_ type: Element.Type) -> TestableObserver<Element> {
        TestableObserver(scheduler: self as AnyObject as! TestScheduler)
    }

    /**
     Schedules an action to be executed at the specified virtual time.

     - parameter time: Absolute virtual time at which to execute the action.
     */
    public func scheduleAt(_ time: TestTime, action: @escaping () -> Void) {
        _ = self.scheduleAbsoluteVirtual((), time: time, action: { _ -> Disposable in
            action()
            return Disposables.create()
        })
    }

    /**
    Adjusts time of scheduling before adding item to schedule queue. If scheduled time is `<= clock`, then it is scheduled at `clock + 1`
    */
    override public func adjustScheduledTime(_ time: VirtualTime) -> VirtualTime {
        time <= self.clock ? self.clock + (self.simulateProcessingDelay ? 1 : 0) : time
    }

    /**
    Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.
    
    - parameter created: Virtual time at which to invoke the factory to create an observable sequence.
    - parameter subscribed: Virtual time at which to subscribe to the created observable sequence.
    - parameter disposed: Virtual time at which to dispose the subscription.
    - parameter create: Factory method to create an observable convertible sequence.
    - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
    */
    public func start<Element, OutputSequence: ObservableConvertibleType>(created: TestTime, subscribed: TestTime, disposed: TestTime, create: @escaping () -> OutputSequence)
        -> TestableObserver<Element> where OutputSequence.Element == Element {
        var source: Observable<Element>?
        var subscription: Disposable?
        let observer = self.createObserver(Element.self)
        
        _ = self.scheduleAbsoluteVirtual((), time: created) { _ in
            source = create().asObservable()
            return Disposables.create()
        }
        
        _ = self.scheduleAbsoluteVirtual((), time: subscribed) { _ in
            subscription = source!.subscribe(observer)
            return Disposables.create()
        }
        
        _ = self.scheduleAbsoluteVirtual((), time: disposed) { _ in
            subscription!.dispose()
            return Disposables.create()
        }

        self.start()
        
        return observer
    }

    /**
     Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.

     Observable sequence will be:
     * created at virtual time `Defaults.created`           -> 100
     * subscribed to at virtual time `Defaults.subscribed`  -> 200

     - parameter disposed: Virtual time at which to dispose the subscription.
     - parameter create: Factory method to create an observable convertible sequence.
     - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
     */
    public func start<Element, OutputSequence: ObservableConvertibleType>(disposed: TestTime, create: @escaping () -> OutputSequence)
        -> TestableObserver<Element> where OutputSequence.Element == Element {
        self.start(created: Defaults.created, subscribed: Defaults.subscribed, disposed: disposed, create: create)
    }

    /**
     Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.

     Observable sequence will be:
     * created at virtual time `Defaults.created`           -> 100
     * subscribed to at virtual time `Defaults.subscribed`  -> 200
     * subscription will be disposed at `Defaults.disposed` -> 1000

     - parameter create: Factory method to create an observable convertible sequence.
     - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
     */
    public func start<Element, OutputSequence: ObservableConvertibleType>(_ create: @escaping () -> OutputSequence)
        -> TestableObserver<Element> where OutputSequence.Element == Element {
         self.start(created: Defaults.created, subscribed: Defaults.subscribed, disposed: Defaults.disposed, create: create)
    }
}


