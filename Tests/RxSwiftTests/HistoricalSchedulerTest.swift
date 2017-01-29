//
//  HistoricalSchedulerTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest
import struct Foundation.Date

class HistoricalSchedulerTest : RxTest {

}

extension HistoricalSchedulerTest {
    func testHistoricalScheduler_initialClock() {
        let scheduler = HistoricalScheduler(initialClock: Date(timeIntervalSince1970: 10.0))
        XCTAssertEqual(scheduler.now, Date(timeIntervalSince1970: 10.0))
        XCTAssertEqual(scheduler.clock, Date(timeIntervalSince1970: 10.0))
    }

    func testHistoricalScheduler_start() {
        let scheduler = HistoricalScheduler()

        var times: [Date] = []

        _ = scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.now)
            _ = scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.now)
                return Disposables.create()
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.now)
                return Disposables.create()
            }
        }

        scheduler.start()

        XCTAssertEqual(times, [
            Date(timeIntervalSince1970: 10.0),
            Date(timeIntervalSince1970: 10.0),
            Date(timeIntervalSince1970: 30.0)
        ])
    }

    func testHistoricalScheduler_disposeStart() {
        let scheduler = HistoricalScheduler()

        var times: [Date] = []

        _ = scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.now)
            let d = scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.now)
                return Disposables.create()
            }
            let d2 = scheduler.schedule(()) { _ in
                times.append(scheduler.now)
                return Disposables.create()
            }

            d2.dispose()
            d.dispose()
            return Disposables.create()
        }

        scheduler.start()

        XCTAssertEqual(times, [
            Date(timeIntervalSince1970: 10.0),
            ])
    }

    func testHistoricalScheduler_advanceToAfter() {
        let scheduler = HistoricalScheduler()

        var times: [Date] = []

        _ = scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.now)
            _ = scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.now)
                return Disposables.create()
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.now)
                return Disposables.create()
            }
        }

        scheduler.advanceTo(Date(timeIntervalSince1970: 100.0))

        XCTAssertEqual(times, [
            Date(timeIntervalSince1970: 10.0),
            Date(timeIntervalSince1970: 10.0),
            Date(timeIntervalSince1970: 30.0)
        ])
    }

    func testHistoricalScheduler_advanceToBefore() {
        let scheduler = HistoricalScheduler()

        var times: [Date] = []

        _ = scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)
            _ = scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }
            return scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }
        }

        scheduler.advanceTo(Date(timeIntervalSince1970: 10.0))

        XCTAssertEqual(times, [
            Date(timeIntervalSince1970: 10.0),
            Date(timeIntervalSince1970: 10.0),
        ])
    }

    func testHistoricalScheduler_disposeAdvanceTo() {
        let scheduler = HistoricalScheduler()

        var times: [Date] = []

        _ = scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)
            let d1 = scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }
            let d2 = scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }

            d1.dispose()
            d2.dispose()
            return Disposables.create()
        }

        scheduler.advanceTo(Date(timeIntervalSince1970: 200.0))

        XCTAssertEqual(times, [
            Date(timeIntervalSince1970: 10.0),
        ])
    }

    func testHistoricalScheduler_stop() {
        let scheduler = HistoricalScheduler()

        var times: [Date] = []

        _ = scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)
            _ = scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }
            _ = scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }

            scheduler!.stop()

            return Disposables.create()
        }

        scheduler.start()

        XCTAssertEqual(times, [
            Date(timeIntervalSince1970: 10.0),
            ])
    }

    func testHistoricalScheduler_sleep() {
        let scheduler = HistoricalScheduler()

        var times: [Date] = []

        _ = scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)

            _ = scheduler!.sleep(100)
            _ = scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }
            _ = scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return Disposables.create()
            }


            return Disposables.create()
        }

        scheduler.start()

        XCTAssertEqual(times, [
            Date(timeIntervalSince1970: 10.0),
            Date(timeIntervalSince1970: 110.0),
            Date(timeIntervalSince1970: 130.0),
            ])
    }
}
