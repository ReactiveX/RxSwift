//
//  RunLoopLock.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 11/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreFoundation
import Foundation
import RxSwift

#if !canImport(Darwin)
import Foundation

let runLoopMode: RunLoop.Mode = .default
let runLoopModeRaw: CFString = unsafeBitCast(runLoopMode.rawValue._bridgeToObjectiveC(), to: CFString.self)
#else
let runLoopMode: CFRunLoopMode = .defaultMode
let runLoopModeRaw = runLoopMode.rawValue
#endif

final class RunLoopLock {
    let currentRunLoop: CFRunLoop

    let calledRun = AtomicInt(0)
    let calledStop = AtomicInt(0)
    var timeout: TimeInterval?

    init(timeout: TimeInterval?) {
        self.timeout = timeout
        currentRunLoop = CFRunLoopGetCurrent()
    }

    func dispatch(_ action: @escaping () -> Void) {
        CFRunLoopPerformBlock(currentRunLoop, runLoopModeRaw) {
            if CurrentThreadScheduler.isScheduleRequired {
                _ = CurrentThreadScheduler.instance.schedule(()) { _ in
                    action()
                    return Disposables.create()
                }
            } else {
                action()
            }
        }
        CFRunLoopWakeUp(currentRunLoop)
    }

    func stop() {
        if decrement(calledStop) > 1 {
            return
        }
        CFRunLoopPerformBlock(currentRunLoop, runLoopModeRaw) {
            CFRunLoopStop(self.currentRunLoop)
        }
        CFRunLoopWakeUp(currentRunLoop)
    }

    func run() throws {
        if increment(calledRun) != 0 {
            fatalError("Run can be only called once")
        }
        if let timeout {
            #if !canImport(Darwin)
            let runLoopResult = CFRunLoopRunInMode(runLoopModeRaw, timeout, false)
            #else
            let runLoopResult = CFRunLoopRunInMode(runLoopMode, timeout, false)
            #endif

            switch runLoopResult {
            case .finished:
                return
            case .handledSource:
                return
            case .stopped:
                return
            case .timedOut:
                throw RxError.timeout
            default:
                return
            }
        } else {
            CFRunLoopRun()
        }
    }
}
