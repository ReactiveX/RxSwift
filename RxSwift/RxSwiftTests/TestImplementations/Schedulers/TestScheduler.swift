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
    
    func start<Element : Equatable>(created: Time, subscribed: Time, disposed: Time, create: () -> Observable<Element>) -> MockObserver<Element> {
        var source : Observable<Element>? = nil
        var subscription : Disposable? = nil
        var observer = MockObserver<Element>(scheduler: self)
        
        let state : Void = ()
        
        self.schedule(state, date: created) { (state) in
            source = create()
            return SuccessResult
        }
        
        self.schedule(state, date: subscribed) { (state) in
            subscription = source!.subscribe(ObserverOf(observer)).value!
            return SuccessResult
        }
        
        self.schedule(state, date: disposed) { (state) in
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