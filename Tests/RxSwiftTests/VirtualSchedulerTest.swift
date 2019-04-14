//
//  VirtualSchedulerTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest
#if os(Linux)
    import Glibc
#endif

import struct Foundation.Date

class VirtualSchedulerTest : RxTest {

}

extension VirtualSchedulerTest {
    func testVirtualScheduler_initialClock() {
        let scheduler = TestVirtualScheduler(initialClock: 10)
        XCTAssertEqual(scheduler.now, Date(timeIntervalSince1970: 100.0))
        XCTAssertEqual(scheduler.clock, 10)
    }

    func testVirtualScheduler_start() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        _ = scheduler.scheduleRelative((), dueTime: .seconds(10)) { _ in
            times.append(scheduler.clock)
            _ = scheduler.scheduleRelative((), dueTime: .seconds(20)) { _ in
                times.append(scheduler.clock)
                return Disposables.create()
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.clock)
                return Disposables.create()
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

        _ = scheduler.scheduleRelative((), dueTime: .seconds(10)) { _ in
            times.append(scheduler.clock)
            let d = scheduler.scheduleRelative((), dueTime: .seconds(20)) { _ in
                times.append(scheduler.clock)
                return Disposables.create()
            }
            let d2 = scheduler.schedule(()) { _ in
                times.append(scheduler.clock)
                return Disposables.create()
            }

            d2.dispose()
            d.dispose()
            return Disposables.create()
        }

        scheduler.start()

        XCTAssertEqual(times, [
                1
            ])
    }

    func testVirtualScheduler_advanceToAfter() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        _ = scheduler.scheduleRelative((), dueTime: .seconds(10)) { _ in
            times.append(scheduler.clock)
            _ = scheduler.scheduleRelative((), dueTime: .seconds(20)) { _ in
                times.append(scheduler.clock)
                return Disposables.create()
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.clock)
                return Disposables.create()
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

        _ = scheduler.scheduleRelative((), dueTime: .seconds(10)) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            _ = scheduler!.scheduleRelative((), dueTime: .seconds(20)) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
            }
            return scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
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

        _ = scheduler.scheduleRelative((), dueTime: .seconds(10)) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            let d1 = scheduler!.scheduleRelative((), dueTime: .seconds(20)) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
            }
            let d2 = scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
            }

            d1.dispose()
            d2.dispose()
            return Disposables.create()
        }

        scheduler.advanceTo(20)

        XCTAssertEqual(times, [
            1,
        ])
    }

    func testVirtualScheduler_stop() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        _ = scheduler.scheduleRelative((), dueTime: .seconds(10)) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            _ = scheduler!.scheduleRelative((), dueTime: .seconds(20)) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
            }
            _ = scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
            }

            scheduler!.stop()

            return Disposables.create()
        }

        scheduler.start()

        XCTAssertEqual(times, [
            1,
            ])
    }

    func testVirtualScheduler_sleep() {
        let scheduler = TestVirtualScheduler()

        var times: [Int] = []

        _ = scheduler.scheduleRelative((), dueTime: .seconds(10)) { [weak scheduler] _ in
            times.append(scheduler!.clock)
            scheduler!.sleep(10)
            _ = scheduler!.scheduleRelative((), dueTime: .seconds(20)) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
            }
            _ = scheduler!.schedule(()) { _ in
                times.append(scheduler!.clock)
                return Disposables.create()
            }

            return Disposables.create()
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
            #if os(Linux)
            let random = Int(Glibc.random() % 10000)
            #else
            let random = Int(arc4random() % 10000)
            #endif
            times.append(random)
            _ = scheduler.scheduleRelative((), dueTime: .seconds(10 * random)) { [weak scheduler] _ in
                ticks.append(scheduler!.clock)
                return Disposables.create()
            }
        }

        scheduler.start()

        times = times.sorted()
        XCTAssertEqual(times, ticks)
    }
}
