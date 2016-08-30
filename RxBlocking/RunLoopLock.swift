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

typealias AtomicInt = Int32

#if os(Linux)
  func AtomicIncrement(increment: UnsafeMutablePointer<AtomicInt>) -> AtomicInt {
      increment.memory = increment.memory + 1
      return increment.memory
  }

  func AtomicDecrement(increment: UnsafeMutablePointer<AtomicInt>) -> AtomicInt {
      increment.memory = increment.memory - 1
      return increment.memory
  }
#else
  let AtomicIncrement = OSAtomicIncrement32
  let AtomicDecrement = OSAtomicDecrement32
#endif

class RunLoopLock {
    let _currentRunLoop: CFRunLoop

    var _calledRun: AtomicInt = 0
    var _calledStop: AtomicInt = 0
    var _timeout: RxTimeInterval?

    init(timeout: RxTimeInterval?) {
        _timeout = timeout
        _currentRunLoop = CFRunLoopGetCurrent()
    }

    func dispatch(_ action: @escaping () -> ()) {
        CFRunLoopPerformBlock(_currentRunLoop, CFRunLoopMode.defaultMode.rawValue) {
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
        CFRunLoopWakeUp(_currentRunLoop)
    }

    func stop() {
        if AtomicIncrement(&_calledStop) != 1 {
            return
        }
        CFRunLoopPerformBlock(_currentRunLoop, CFRunLoopMode.defaultMode.rawValue) {
            CFRunLoopStop(self._currentRunLoop)
        }
        CFRunLoopWakeUp(_currentRunLoop)
    }

    func run() throws {
        if AtomicIncrement(&_calledRun) != 1 {
            fatalError("Run can be only called once")
        }
        if let timeout = _timeout {
            switch CFRunLoopRunInMode(CFRunLoopMode.defaultMode, timeout, false) {
            case .finished:
                return
            case .handledSource:
                return
            case .stopped:
                return
            case .timedOut:
                throw RxError.timeout
            }
        }
        else {
            CFRunLoopRun()
        }
    }
}
