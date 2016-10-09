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
  func AtomicIncrement(_ increment: UnsafeMutablePointer<AtomicInt>) -> AtomicInt {
      increment.pointee = increment.pointee + 1
      return increment.pointee
  }

  func AtomicDecrement(_ increment: UnsafeMutablePointer<AtomicInt>) -> AtomicInt {
      increment.pointee = increment.pointee - 1
      return increment.pointee
  }
#else
  let AtomicIncrement = OSAtomicIncrement32Barrier
  let AtomicDecrement = OSAtomicDecrement32Barrier
#endif

#if os(Linux)
import Dispatch

class RunLoopLock {
    let _queue = DispatchQueue(label: "Worker")
    let _sema = DispatchSemaphore(value: 0)
    let _group = DispatchGroup()
    var _timeout: TimeInterval?
    
    init(timeout: TimeInterval?) {
        self._timeout = timeout
    }
    
    func dispatch(_ action: @escaping () -> ()) {
        _queue.async(group: _group, execute: action)
    }
    
    func stop() {
        _queue.suspend()
        _sema.signal()
    }
    
    func run() throws {
        _group.notify(queue: _queue) { [weak self] in
            self?._sema.signal()
        }
        if let timeout = _timeout {
            let result = _sema.wait(timeout: DispatchTime.now() + timeout)
            if result == .timedOut {
                _queue.suspend()
                throw RxError.timeout
            }
        } else {
            _sema.wait()
        }
    }
    
}
#else
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
#endif
