//
//  TestScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

func createHotObservable<Element>(scheduler: TestScheduler, events: [Recorded<Element>]) -> HotObservable<Element> {
    return HotObservable(testScheduler: scheduler, recordedEvents: events)
}

func createColdObservable<Element>(scheduler: TestScheduler, events: [Recorded<Element>]) -> ColdObservable<Element> {
    return ColdObservable(testScheduler: scheduler, recordedEvents: events)
}

func createObserver<E>(scheduler: TestScheduler) -> MockObserver<E> {
    return MockObserver(scheduler: scheduler)
}

class TestScheduler : VirtualTimeSchedulerBase {
    
    override init(initialClock: Time) {
        super.init(initialClock: initialClock)
    }
    
    func createHotObservable<Element>(events: [Recorded<Element>]) -> HotObservable<Element> {
        return HotObservable(testScheduler: self as AnyObject as! TestScheduler, recordedEvents: events)
    }
    
    func createColdObservable<Element>(events: [Recorded<Element>]) -> ColdObservable<Element> {
        return ColdObservable(testScheduler: self as AnyObject as! TestScheduler, recordedEvents: events)
    }
    
    func createObserver<E>() -> MockObserver<E> {
        return MockObserver(scheduler: self as AnyObject as! TestScheduler)
    }
    
    func scheduleAt(time: Time, action: () -> Void) {
        self.schedule((), time: time) { _ in
            action()
            return NopDisposable.instance
        }
    }
    
    func start<Element : Equatable>(created: Time, subscribed: Time, disposed: Time, create: () -> Observable<Element>) -> MockObserver<Element> {
        var source : Observable<Element>? = nil
        var subscription : Disposable? = nil
        let observer: MockObserver<Element> = createObserver()
        
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
    
    func start<Element : Equatable>(disposed: Time, create: () -> Observable<Element>) -> MockObserver<Element> {
        return start(RxTest.Defaults.created, subscribed: RxTest.Defaults.subscribed, disposed: disposed, create: create)
    }

    func start<Element : Equatable>(create: () -> Observable<Element>) -> MockObserver<Element> {
        return start(RxTest.Defaults.created, subscribed: RxTest.Defaults.subscribed, disposed: RxTest.Defaults.disposed, create: create)
    }
}