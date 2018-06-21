//
//  MainSchedulerTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import CoreFoundation

import RxSwift
import XCTest

class MainSchedulerTest : RxTest {

}

extension MainSchedulerTest {
    func runRunLoop() {
        for _ in 0 ..< 10 {
            let currentRunLoop = CFRunLoopGetCurrent()
            DispatchQueue.main.async {
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
        var executedImmediately = false
        _ = MainScheduler.instance.schedule(()) { s in
            executedImmediately = true
            messages.append(1)
            _ = MainScheduler.instance.schedule(()) { s in
                messages.append(3)
                _ = MainScheduler.instance.schedule(()) {
                    messages.append(5)
                    return Disposables.create()
                }
                messages.append(4)
                return Disposables.create()
            }
            messages.append(2)
            return Disposables.create()
        }

        XCTAssertTrue(executedImmediately)

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
                    return Disposables.create()
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
                    return Disposables.create()
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
