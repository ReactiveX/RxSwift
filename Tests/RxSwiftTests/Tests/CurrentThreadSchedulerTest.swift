//
//  CurrentThreadSchedulerTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class CurrentThreadSchedulerTest : RxTest {

}

extension CurrentThreadSchedulerTest {
    func testCurrentThreadScheduler_scheduleRequired() {

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var executed = false
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            executed = true
            XCTAssertTrue(!CurrentThreadScheduler.isScheduleRequired)
            return NopDisposable.instance
        }

        XCTAssertTrue(executed)
    }

    func testCurrentThreadScheduler_basicScenario() {

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            messages.append(1)
            CurrentThreadScheduler.instance.schedule(()) { s in
                messages.append(3)
                CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return NopDisposable.instance
                }
                messages.append(4)
                return NopDisposable.instance
            }
            messages.append(2)
            return NopDisposable.instance
        }

        XCTAssertEqual(messages, [1, 2, 3, 4, 5])
    }

    func testCurrentThreadScheduler_disposing1() {

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            messages.append(1)
            let disposable = CurrentThreadScheduler.instance.schedule(()) { s in
                messages.append(3)
                let disposable = CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return NopDisposable.instance
                }
                disposable.dispose()
                messages.append(4)
                return disposable
            }
            messages.append(2)
            return disposable
        }

        XCTAssertEqual(messages, [1, 2, 3, 4])
    }

    func testCurrentThreadScheduler_disposing2() {

        XCTAssertTrue(CurrentThreadScheduler.isScheduleRequired)

        var messages = [Int]()
        _ = CurrentThreadScheduler.instance.schedule(()) { s in
            messages.append(1)
            let disposable = CurrentThreadScheduler.instance.schedule(()) { s in
                messages.append(3)
                let disposable = CurrentThreadScheduler.instance.schedule(()) {
                    messages.append(5)
                    return NopDisposable.instance
                }
                messages.append(4)
                return disposable
            }
            disposable.dispose()
            messages.append(2)
            return disposable
        }

        XCTAssertEqual(messages, [1, 2])
    }
}