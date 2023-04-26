//
//  MockDisposable.swift
//  Tests
//
//  Created by Yury Korolev on 10/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest

final class MockDisposable : Disposable
{
    var ticks = [Int]()
    private let scheduler: TestScheduler
    
    init(scheduler: TestScheduler) {
        self.scheduler = scheduler
        ticks.append(self.scheduler.clock)
    }
    
    func dispose() {
        ticks.append(self.scheduler.clock)
    }
}
