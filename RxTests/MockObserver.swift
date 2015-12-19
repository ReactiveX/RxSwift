//
//  MockObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

public class MockObserver<ElementType>
    : ObserverType {
    public typealias Element = ElementType
    
    public let scheduler: TestScheduler
    public private(set) var messages: [Recorded<Element>]
    
    init(scheduler: TestScheduler) {
        self.scheduler = scheduler
        self.messages = []
    }
    
    public func on(event: Event<Element>) {
        messages.append(Recorded(time: scheduler.now, event: event))
    }
}