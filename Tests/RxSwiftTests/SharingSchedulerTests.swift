//
//  SharingSchedulerTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 8/27/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest
#if os(Linux)
    import Glibc
#endif

import struct Foundation.Date

class SharingSchedulerTest : RxTest {

}

extension SharingSchedulerTest {
    func testSharingSchedulerMockMake() {
        XCTAssertTrue(SharingScheduler.make() is MainScheduler)

        SharingScheduler.mock(makeScheduler: { Scheduler1() }) {
            XCTAssertTrue(SharingScheduler.make() is Scheduler1)
            SharingScheduler.mock(makeScheduler: { Scheduler2() }) {
                XCTAssertTrue(SharingScheduler.make() is Scheduler2)
            }
            XCTAssertTrue(SharingScheduler.make() is Scheduler1)
        }
    }

    func testSharingSchedulerMockInstance() {
        XCTAssertTrue(SharingScheduler.make() is MainScheduler)

        let scheduler1 = Scheduler1()
        SharingScheduler.mock(scheduler: scheduler1) {
            XCTAssertTrue(SharingScheduler.make() is Scheduler1 && SharingScheduler.make() as! Scheduler1 === scheduler1)
            let scheduler2 = Scheduler2()
            SharingScheduler.mock(scheduler: scheduler2) {
                XCTAssertTrue(SharingScheduler.make() is Scheduler2 && SharingScheduler.make() as! Scheduler2 === scheduler2)
            }
            XCTAssertTrue(SharingScheduler.make() is Scheduler1)
        }
    }
}

class Scheduler1: SchedulerType {
    var now : RxTime {
        fatalError()
    }

    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        fatalError()
    }

    func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        fatalError()
    }

    func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        fatalError()
    }
}

class Scheduler2: SchedulerType {
    var now : RxTime {
        fatalError()
    }

    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        fatalError()
    }

    func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        fatalError()
    }

    func schedulePeriodic<StateType>(_ state: StateType, startAfter: RxTimeInterval, period: RxTimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        fatalError()
    }
}
