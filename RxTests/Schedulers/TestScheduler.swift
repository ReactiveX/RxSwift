//
//  TestScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
Virtual time scheduler used for testing applications and libraries built using RxSwift.
*/
public class TestScheduler : VirtualTimeSchedulerBase {

    /**
     Default values of scheduler times.
    */
    public struct Defaults {
        /**
         Default absolute time when to create tested observable sequence.
        */
        public static let created = 100
        /**
         Default absolute time when to subscribe to tested observable sequence.
        */
        public static let subscribed = 200
        /**
         Default absolute time when to dispose subscription to tested observable sequence.
        */
        public static let disposed = 1000
    }

    /**
     Creates a new test scheduler.
     
     - parameter initialClock: Initial value for the clock.
    */
    public override init(initialClock: Time) {
        super.init(initialClock: initialClock)
    }

    /**
    Creates a hot observable using the specified timestamped events.
     
    - parameter events: Events to surface through the created sequence at their specified absolute virtual times.
    - returns: Hot observable sequence that can be used to assert the timing of subscriptions and events.
    */
    public func createHotObservable<Element>(events: [Recorded<Event<Element>>]) -> HotObservable<Element> {
        return HotObservable(testScheduler: self as AnyObject as! TestScheduler, recordedEvents: events)
    }

    /**
    Creates a cold observable using the specified timestamped events.
     
     - parameter events: Events to surface through the created sequence at their specified virtual time offsets from the sequence subscription time.
     - returns: Cold observable sequence that can be used to assert the timing of subscriptions and events.
    */
    public func createColdObservable<Element>(events: [Recorded<Event<Element>>]) -> ColdObservable<Element> {
        return ColdObservable(testScheduler: self as AnyObject as! TestScheduler, recordedEvents: events)
    }

    /**
    Creates an observer that records received events and timestamps those.
    
     - parameter type: Optional type hint of the observed sequence elements.
     - returns: Observer that can be used to assert the timing of events.
    */
    public func createObserver<E>(type: E.Type) -> MockObserver<E> {
        return MockObserver(scheduler: self as AnyObject as! TestScheduler)
    }

    /**
     Schedules an action to be executed at the specified virtual time.
     
     - parameter time: Absolute virtual time at which to execute the action.
    */
    public func scheduleAt(time: Time, action: () -> Void) {
        self.schedule((), time: time) { _ in
            action()
            return NopDisposable.instance
        }
    }

    /**
    Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.
    
    - parameter create: Factory method to create an observable sequence.
    - parameter created: Virtual time at which to invoke the factory to create an observable sequence.
    - parameter subscribed: Virtual time at which to subscribe to the created observable sequence.
    - parameter disposed: Virtual time at which to dispose the subscription.
    - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
    */
    public func start<Element>(created: Time, subscribed: Time, disposed: Time, create: () -> Observable<Element>) -> MockObserver<Element> {
        var source : Observable<Element>? = nil
        var subscription : Disposable? = nil
        let observer: MockObserver<Element> = createObserver(Element)
        
        let state : Void = ()
        
        self.schedule(state, time: created) { (state) in
            source = create()
            return NopDisposable.instance
        }
        
        self.schedule(state, time: subscribed) { (state) in
            subscription = source!.subscribe(observer)
            return NopDisposable.instance
        }
        
        self.schedule(state, time: disposed) { (state) in
            subscription!.dispose()
            return NopDisposable.instance
        }

        start()
        
        return observer
    }

    /**
     Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.

     Observable sequence will be:
     * created at virtual time `Defaults.created`           -> 100
     * subscribed to at virtual time `Defaults.subscribed`  -> 200

     - parameter create: Factory method to create an observable sequence.
     - parameter disposed: Virtual time at which to dispose the subscription.
     - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
     */
    public func start<Element>(disposed: Time, create: () -> Observable<Element>) -> MockObserver<Element> {
        return start(Defaults.created, subscribed: Defaults.subscribed, disposed: disposed, create: create)
    }

    /**
     Starts the test scheduler and uses the specified virtual times to invoke the factory function, subscribe to the resulting sequence, and dispose the subscription.

     Observable sequence will be:
     * created at virtual time `Defaults.created`           -> 100
     * subscribed to at virtual time `Defaults.subscribed`  -> 200
     * subscription will be disposed at `Defaults.disposed` -> 1000

     - parameter create: Factory method to create an observable sequence.
     - returns: Observer with timestamped recordings of events that were received during the virtual time window when the subscription to the source sequence was active.
     */
    public func start<Element>(create: () -> Observable<Element>) -> MockObserver<Element> {
        return start(Defaults.created, subscribed: Defaults.subscribed, disposed: Defaults.disposed, create: create)
    }
}