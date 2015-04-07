//
//  MockObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Rx

class MockObserver<ElementType : Equatable> : ObserverClassType {
    typealias Element = ElementType
    
    let scheduler: TestScheduler
    var messages: [Recorded<Element>]
    
    init(scheduler: TestScheduler) {
        self.scheduler = scheduler
        self.messages = []
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        messages.append(Recorded(time: scheduler.now, event: event))
        return SuccessResult
    }
}