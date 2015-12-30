//
//  MockDisposable.swift
//  RxTests
//
//  Created by Yury Korolev on 10/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxTests

class MockDisposable : Disposable
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