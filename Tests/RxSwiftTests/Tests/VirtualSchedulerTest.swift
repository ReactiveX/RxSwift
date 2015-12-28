//
//  VirtualSchedulerTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//
//

import Foundation
import RxSwift
import XCTest

class VirtualSchedulerTest : RxTest {

}

extension VirtualSchedulerTest {
    func testVirtualScheduler_initialClock() {
        let scheduler = TestVirtualScheduler(initialClock: 10)
        XCTAssertEqual(scheduler.now, NSDate(timeIntervalSince1970: 100.0))
        XCTAssertEqual(scheduler.clock, 10)
    }

    func testVirtualScheduler_start() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.clock)
            scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.clock)
                return NopDisposable.instance
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.clock)
                return NopDisposable.instance
            }
        }

        scheduler.start()

        XCTAssertEqual(times, [
            1,
            1,
            3
        ])
    }

    func testVirtualScheduler_disposeStart() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.clock)
            let d = scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.clock)
                return NopDisposable.instance
            }
            let d2 = scheduler.schedule(()) { _ in
                times.append(scheduler.clock)
                return NopDisposable.instance
            }

            d2.dispose()
            d.dispose()
            return NopDisposable.instance
        }

        scheduler.start()

        XCTAssertEqual(times, [
                1
            ])
    }

    func testVirtualScheduler_advanceToAfter() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.clock)
            scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.clock)
                return NopDisposable.instance
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.clock)
                return NopDisposable.instance
            }
        }

        scheduler.advanceTo(10)

        XCTAssertEqual(times, [
            1,
            1,
            3
        ])
    }

    func testVirtualScheduler_advanceToBefore() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }
            return scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }
        }

        scheduler.advanceTo(1)

        XCTAssertEqual(times, [
            1,
            1
        ])
    }

    func testVirtualScheduler_disposeAdvanceTo() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            let d1 = scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }
            let d2 = scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }

            d1.dispose()
            d2.dispose()
            return NopDisposable.instance
        }

        scheduler.advanceTo(20)

        XCTAssertEqual(times, [
            1,
        ])
    }
}