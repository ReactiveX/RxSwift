//
//  TestableObserver.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// Observer that records events together with virtual time when they were received.
public final class TestableObserver<Element>
    : ObserverType {
    private let _scheduler: TestScheduler

    /// Recorded events.
    public private(set) var events = [Recorded<Event<Element>>]()
    
    init(scheduler: TestScheduler) {
        self._scheduler = scheduler
    }

    /// Notify observer about sequence event.
    ///
    /// - parameter event: Event that occurred.
    public func on(_ event: Event<Element>) {
        self.events.append(Recorded(time: self._scheduler.clock, value: event))
    }
}
