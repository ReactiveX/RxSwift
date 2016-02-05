//
//  RunLoopLock.swift
//  Rx
//
//  Created by Krunoslav Zaher on 11/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif

class RunLoopLock {
    let currentRunLoop: CFRunLoopRef

    var calledRun: Int32 = 0
    var calledStop: Int32 = 0

    init() {
        currentRunLoop = CFRunLoopGetCurrent()
    }

    func dispatch(action: () -> ()) {
        CFRunLoopPerformBlock(currentRunLoop, kCFRunLoopDefaultMode) {
            if CurrentThreadScheduler.isScheduleRequired {
                CurrentThreadScheduler.instance.schedule(()) { _ in
                    action()
                    return NopDisposable.instance
                }
            }
            else {
                action()
            }
        }
        CFRunLoopWakeUp(currentRunLoop)
    }

    func stop() {
        if OSAtomicIncrement32(&calledStop) != 1 {
            return
        }
        CFRunLoopPerformBlock(currentRunLoop, kCFRunLoopDefaultMode) {
            CFRunLoopStop(self.currentRunLoop)
        }
        CFRunLoopWakeUp(currentRunLoop)
    }

    func run() {
        if OSAtomicIncrement32(&calledRun) != 1 {
            fatalError("Run can be only called once")
        }
        CFRunLoopRun()
    }
}
