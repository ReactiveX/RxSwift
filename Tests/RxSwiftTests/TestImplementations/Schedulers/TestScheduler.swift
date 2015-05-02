//
//  TestScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class TestScheduler : VirtualTimeSchedulerBase {
    func advanceTimeFor(interval: Time) {
        
    }
    
    func createHotObservable<Element>(events: [Recorded<Element>]) -> HotObservable<Element> {
        return HotObservable(testScheduler: self, recordedEvents: events)
    }
    
    func createColdObservable<Element>(events: [Recorded<Element>]) -> ColdObservable<Element> {
        return ColdObservable(testScheduler: self, recordedEvents: events)
    }
    
    func createObserver<E>() -> MockObserver<E> {
        return MockObserver(scheduler: self)
    }
    
    func scheduleAt(time: Time, action: () -> Void) {
        self.schedule((), time: time) { _ in
            action()
            return SuccessResult
        }
    }
    
    func start<Element : Equatable>(created: Time, subscribed: Time, disposed: Time, create: () -> Observable<Element>) -> MockObserver<Element> {
        var source : Observable<Element>? = nil
        var subscription : Disposable? = nil
        var observer: MockObserver<Element> = createObserver()
        
        let state : Void = ()
        
        self.schedule(state, time: created) { (state) in
            source = create()
            return SuccessResult
        }
        
        self.schedule(state, time: subscribed) { (state) in
            subscription = source!.subscribe(observer)
            return SuccessResult
        }
        
        self.schedule(state, time: disposed) { (state) in
            subscription!.dispose()
            return SuccessResult
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