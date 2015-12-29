//
//  TestableObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
 Observer that records events together with virtual time when they were received.
*/
public class TestableObserver<ElementType>
    : ObserverType {
    public typealias Element = ElementType
    
    private let _scheduler: TestScheduler

    /**
    Recorded events.
    */
    public private(set) var events = [Recorded<Event<Element>>]()
    
    init(scheduler: TestScheduler) {
        _scheduler = scheduler
    }

    /**
    Notify observer about sequence event.

    - parameter event: Event that occured.
    */
    public func on(event: Event<Element>) {
        events.append(Recorded(time: _scheduler.clock, event: event))
    }
}