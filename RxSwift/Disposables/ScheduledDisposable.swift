//
//  ScheduledDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/13/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ScheduledDisposable : Cancelable {
    public let scheduler: ImmediateScheduler
    var _disposable: Disposable?
    var lock = SpinLock()

    public var disposable: Disposable {
        get {
            return lock.calculateLocked {
                _disposable ?? NopDisposable.instance
            }
        }
    }
    
    public var disposed: Bool {
        get {
            return lock.calculateLocked {
                return _disposable == nil
            }
        }
    }
    
    init(scheduler: ImmediateScheduler, disposable: Disposable) {
        self.scheduler = scheduler
        self._disposable = disposable
    }
    
    public func dispose() {
        scheduler.schedule(()) {
            self.disposeInner()
            return NopDisposable.instance
        }
    }
    
    public func disposeInner() {
        lock.performLocked {
            if let disposable = _disposable {
                disposable.dispose()
                _disposable = nil
            }
        }
    }
}