//
//  ScheduledDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/13/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents a disposable resource whose disposal invocation will be scheduled on the specified scheduler.
*/
public class ScheduledDisposable : Cancelable {
    public let scheduler: ImmediateScheduler
    var _disposable: Disposable?
    var lock = SpinLock()

    var disposable: Disposable {
        get {
            return lock.calculateLocked {
                _disposable ?? NopDisposable.instance
            }
        }
    }
    
    /**
    - returns: Was resource disposed.
    */
    public var disposed: Bool {
        get {
            return lock.calculateLocked {
                return _disposable == nil
            }
        }
    }
    
    /**
    Initializes a new instance of the `ScheduledDisposable` that uses a `scheduler` on which to dispose the `disposable`.
    
    - parameter scheduler: Scheduler where the disposable resource will be disposed on.
    - parameter disposable: Disposable resource to dispose on the given scheduler.
    */
    init(scheduler: ImmediateScheduler, disposable: Disposable) {
        self.scheduler = scheduler
        self._disposable = disposable
    }
    
    /**
    Disposes the wrapped disposable on the provided scheduler.
    */
    public func dispose() {
        scheduler.schedule(()) {
            self.disposeInner()
            return NopDisposable.instance
        }
    }
    
    func disposeInner() {
        lock.performLocked {
            if let disposable = _disposable {
                disposable.dispose()
                _disposable = nil
            }
        }
    }
}