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
    public let scheduler: ImmediateSchedulerType
    
    private var _disposed: Int32 = 0
    
    // state
    private var _disposable: Disposable?

    /**
    - returns: Was resource disposed.
    */
    public var disposed: Bool {
        get {
            return _disposed == 1
        }
    }
    
    /**
    Initializes a new instance of the `ScheduledDisposable` that uses a `scheduler` on which to dispose the `disposable`.
    
    - parameter scheduler: Scheduler where the disposable resource will be disposed on.
    - parameter disposable: Disposable resource to dispose on the given scheduler.
    */
    init(scheduler: ImmediateSchedulerType, disposable: Disposable) {
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
        if OSAtomicCompareAndSwap32(0, 1, &_disposed) {
            _disposable!.dispose()
            _disposable = nil
        }
    }
}