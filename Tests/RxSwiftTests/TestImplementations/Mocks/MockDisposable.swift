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
    private let _scheduler: TestScheduler
    
    init(scheduler: TestScheduler) {
        _scheduler = scheduler
        ticks.append(_scheduler.clock)
    }
    
    func dispose() {
        ticks.append(_scheduler.clock)
    }
}
