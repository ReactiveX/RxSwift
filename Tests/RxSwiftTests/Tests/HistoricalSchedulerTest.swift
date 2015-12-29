//
//  HistoricalSchedulerTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class HistoricalSchedulerTest : RxTest {

}

extension HistoricalSchedulerTest {
    func testHistoricalScheduler_initialClock() {
        let scheduler = HistoricalScheduler(initialClock: NSDate(timeIntervalSince1970: 10.0))
        XCTAssertEqual(scheduler.now, NSDate(timeIntervalSince1970: 10.0))
        XCTAssertEqual(scheduler.clock, NSDate(timeIntervalSince1970: 10.0))
    }

    func testHistoricalScheduler_start() {
        let scheduler = HistoricalScheduler()

        var times: [NSDate] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.now)
            scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.now)
                return NopDisposable.instance
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.now)
                return NopDisposable.instance
            }
        }

        scheduler.start()

        XCTAssertEqual(times, [
            NSDate(timeIntervalSince1970: 10.0),
            NSDate(timeIntervalSince1970: 10.0),
            NSDate(timeIntervalSince1970: 30.0)
        ])
    }

    func testHistoricalScheduler_disposeStart() {
        let scheduler = HistoricalScheduler()

        var times: [NSDate] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.now)
            let d = scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.now)
                return NopDisposable.instance
            }
            let d2 = scheduler.schedule(()) { _ in
                times.append(scheduler.now)
                return NopDisposable.instance
            }

            d2.dispose()
            d.dispose()
            return NopDisposable.instance
        }

        scheduler.start()

        XCTAssertEqual(times, [
            NSDate(timeIntervalSince1970: 10.0),
            ])
    }

    func testHistoricalScheduler_advanceToAfter() {
        let scheduler = HistoricalScheduler()

        var times: [NSDate] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { _ in
            times.append(scheduler.now)
            scheduler.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler.now)
                return NopDisposable.instance
            }
            return scheduler.schedule(()) { _ in
                times.append(scheduler.now)
                return NopDisposable.instance
            }
        }

        scheduler.advanceTo(NSDate(timeIntervalSince1970: 100.0))

        XCTAssertEqual(times, [
            NSDate(timeIntervalSince1970: 10.0),
            NSDate(timeIntervalSince1970: 10.0),
            NSDate(timeIntervalSince1970: 30.0)
        ])
    }

    func testHistoricalScheduler_advanceToBefore() {
        let scheduler = HistoricalScheduler()

        var times: [NSDate] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)
            scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }
            return scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }
        }

        scheduler.advanceTo(NSDate(timeIntervalSince1970: 10.0))

        XCTAssertEqual(times, [
            NSDate(timeIntervalSince1970: 10.0),
            NSDate(timeIntervalSince1970: 10.0),
        ])
    }

    func testHistoricalScheduler_disposeAdvanceTo() {
        let scheduler = HistoricalScheduler()

        var times: [NSDate] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)
            let d1 = scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }
            let d2 = scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }

            d1.dispose()
            d2.dispose()
            return NopDisposable.instance
        }

        scheduler.advanceTo(NSDate(timeIntervalSince1970: 200.0))

        XCTAssertEqual(times, [
            NSDate(timeIntervalSince1970: 10.0),
        ])
    }

    func testHistoricalScheduler_stop() {
        let scheduler = HistoricalScheduler()

        var times: [NSDate] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)
            scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }
            scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }

            scheduler!.stop()

            return NopDisposable.instance
        }

        scheduler.start()

        XCTAssertEqual(times, [
            NSDate(timeIntervalSince1970: 10.0),
            ])
    }

    func testHistoricalScheduler_sleep() {
        let scheduler = HistoricalScheduler()

        var times: [NSDate] = []

        scheduler.scheduleRelative((), dueTime: 10.0) { [weak scheduler] _ in
            times.append(scheduler!.now)

            scheduler!.sleep(100)
            scheduler!.scheduleRelative((), dueTime: 20.0) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }
            scheduler!.schedule(()) { _ in
                times.append(scheduler!.now)
                return NopDisposable.instance
            }


            return NopDisposable.instance
        }

        scheduler.start()

        XCTAssertEqual(times, [
            NSDate(timeIntervalSince1970: 10.0),
            NSDate(timeIntervalSince1970: 110.0),
            NSDate(timeIntervalSince1970: 130.0),
            ])
    }
}