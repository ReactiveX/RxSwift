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
    
    private let lock = SpinLock()
    private var disposable: Disposable?
    
    private let scheduler: ImmediateScheduler
    
    /**
    - returns: Was resource disposed.
    */
    public var disposed: Bool {
        return lock.calculateLocked {
            disposable == nil
        }
    }
    
    /**
    Initializes a new instance of the `ScheduledDisposable` that uses a `scheduler` on which to dispose the `disposable`.
    
    - parameter scheduler: Scheduler where the disposable resource will be disposed on.
    - parameter disposable: Disposable resource to dispose on the given scheduler.
    */
    init(scheduler: ImmediateScheduler, disposable: Disposable) {
        self.scheduler = scheduler
        self.disposable = disposable
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
            disposable?.dispose()
            disposable = nil
        }
    }
}