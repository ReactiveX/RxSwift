//
//  VirtualSchedulerTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest
#if os(Linux)
    import Glibc
#endif

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

    func testVirtualScheduler_stop() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }
            scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }

            scheduler!.stop()

            return NopDisposable.instance
        }

        scheduler.start()

        XCTAssertEqual(times, [
            1,
            ])
    }

    func testVirtualScheduler_sleep() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            scheduler!.sleep(10)
            scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }
            scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return NopDisposable.instance
            }

            return NopDisposable.instance
        }

        scheduler.start()

        XCTAssertEqual(times, [
            1,
            11,
            13
            ])
    }

    func testVirtualScheduler_stress() {
        let scheduler = TestVirtualScheduler()

        var times = [Int]()
        var ticks = [Int]()
        for _ in 0 ..< 20000 {
            let random = Int(arc4random() % 10000)
            times.append(random)
            scheduler.scheduleRelative((), dueTime: RxTimeInterval(10 * random)) { [weak scheduler] _ in
                ticks.append(scheduler!.clock)
                return NopDisposable.instance
            }
        }

        scheduler.start()

        times = times.sort()
        XCTAssertEqual(times, ticks)
    }
}
