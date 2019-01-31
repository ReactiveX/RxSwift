//
//  RunLoopLock.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 11/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import CoreFoundation

import RxSwift

#if os(Linux)
    import Foundation
    let runLoopMode: RunLoopMode = RunLoopMode.defaultRunLoopMode
    let runLoopModeRaw: CFString = unsafeBitCast(runLoopMode.rawValue._bridgeToObjectiveC(), to: CFString.self)
#else
    let runLoopMode: CFRunLoopMode = CFRunLoopMode.defaultMode
    let runLoopModeRaw = runLoopMode.rawValue
#endif

final class RunLoopLock {
    let _currentRunLoop: CFRunLoop

    var _calledRun = AtomicInt(0)
    var _calledStop = AtomicInt(0)
    var _timeout: RxTimeInterval?

    init(timeout: RxTimeInterval?) {
        self._timeout = timeout
        self._currentRunLoop = CFRunLoopGetCurrent()
    }

    func dispatch(_ action: @escaping () -> Void) {
        CFRunLoopPerformBlock(self._currentRunLoop, runLoopModeRaw) {
            if CurrentThreadScheduler.isScheduleRequired {
                _ = CurrentThreadScheduler.instance.schedule(()) { _ in
                    action()
                    return Disposables.create()
                }
            }
            else {
                action()
            }
        }
        CFRunLoopWakeUp(self._currentRunLoop)
    }

    func stop() {
        if decrement(&self._calledStop) > 1 {
            return
        }
        CFRunLoopPerformBlock(self._currentRunLoop, runLoopModeRaw) {
            CFRunLoopStop(self._currentRunLoop)
        }
        CFRunLoopWakeUp(self._currentRunLoop)
    }

    func run() throws {
        if increment(&self._calledRun) != 0 {
            fatalError("Run can be only called once")
        }
        if let timeout = self._timeout {
            #if os(Linux)
                switch Int(CFRunLoopRunInMode(runLoopModeRaw, timeout, false)) {
                case kCFRunLoopRunFinished:
                    return
                case kCFRunLoopRunHandledSource:
                    return
                case kCFRunLoopRunStopped:
                    return
                case kCFRunLoopRunTimedOut:
                    throw RxError.timeout
                default:
                    fatalError("This failed because `CFRunLoopRunResult` wasn't bridged to Swift.")
                }
            #else
                switch CFRunLoopRunInMode(runLoopMode, timeout, false) {
                case .finished:
                    return
                case .handledSource:
                    return
                case .stopped:
                    return
                case .timedOut:
                    throw RxError.timeout
                }
            #endif
        }
        else {
            CFRunLoopRun()
        }
    }
}
