//
//  TestableObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
 Observable sequence that records subscription lifetimes and timestamped events sent to observers.
*/
public class TestableObservable<Element>
    : ObservableType {
    public typealias E = Element
    /**
     Subscriptions recorded during observable lifetime.
    */
    public internal(set) var subscriptions: [Subscription]

    /**
     List of events to replay for all subscribers.
     
     Event times represent absolute `TestScheduler` time.
    */
    public internal(set) var recordedEvents: [Recorded<Event<Element>>]
    
    /**
     Parent test scheduler.
     */
    internal let testScheduler: TestScheduler

    init(testScheduler: TestScheduler, recordedEvents: [Recorded<Event<Element>>]) {
        self.testScheduler = testScheduler
        self.recordedEvents = recordedEvents
        self.subscriptions = []
    }

    public func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        fatalError("Abstract method")
    }
}