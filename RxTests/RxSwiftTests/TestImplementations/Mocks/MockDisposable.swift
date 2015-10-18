//
//  MockDisposable.swift
//  RxTests
//
//  Created by Yury Korolev on 10/17/15.
//
//

import Foundation
import RxSwift

class MockDisposable : Disposable
{
    var ticks = [Int]()
    private let _scheduler: TestScheduler
    
    init(scheduler: TestScheduler) {
        _scheduler = scheduler
        ticks.append(_scheduler.now)
    }
    
    func dispose() {
        ticks.append(_scheduler.now)
    }
}