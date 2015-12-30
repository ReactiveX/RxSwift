//
//  MainSchedulerTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

import RxSwift
import XCTest

class MainSchedulerTest : RxTest {

}

extension MainSchedulerTest {
    func runRunLoop() {
        for _ in 0 ..< 10 {
            let currentRunLoop = CFRunLoopGetCurrent()
            dispatch_async(dispatch_get_main_queue()) {
                CFRunLoopStop(currentRunLoop)
            }

            CFRunLoopWakeUp(currentRunLoop)
            CFRunLoopRun()
        }
    }
}

extension MainSchedulerTest {
    func testMainScheduler_basicScenario() {

        var messages = [Int]()
        var executedImmediatelly = false
        _ = MainScheduler.instance.schedule(()) { s in
            executedImmediatelly = true
            messages.append(1)
            MainScheduler.instance.schedule(()) { s in
                messages.append(3)
                MainScheduler.instance.schedule(()) {
                    messages.append(5)
                    return NopDisposable.instance
                }
                messages.append(4)
                return NopDisposable.instance
            }
            messages.append(2)
            return NopDisposable.instance
        }

        XCTAssertTrue(executedImmediatelly)

        runRunLoop()

        XCTAssertEqual(messages, [1, 2, 3, 4, 5])
    }

    func testMainScheduler_disposing1() {

        var messages = [Int]()
        _ = MainScheduler.instance.schedule(()) { s in
            messages.append(1)
            let disposable = MainScheduler.instance.schedule(()) { s in
                messages.append(3)
                let disposable = MainScheduler.instance.schedule(()) {
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

        runRunLoop()

        XCTAssertEqual(messages, [1, 2, 3, 4])
    }

    func testMainScheduler_disposing2() {

        var messages = [Int]()
        _ = MainScheduler.instance.schedule(()) { s in
            messages.append(1)
            let disposable = MainScheduler.instance.schedule(()) { s in
                messages.append(3)
                let disposable = MainScheduler.instance.schedule(()) {
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

        runRunLoop()

        XCTAssertEqual(messages, [1, 2])
    }
}