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

class RunLoopLock : NSObject {
    let currentRunLoop: CFRunLoopRef

    override init() {
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
        CFRunLoopPerformBlock(currentRunLoop, kCFRunLoopDefaultMode) {
            CFRunLoopStop(self.currentRunLoop)
        }
        CFRunLoopWakeUp(currentRunLoop)
    }

    func run() {
        CFRunLoopRun()
    }
}
