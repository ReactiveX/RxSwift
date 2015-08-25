//
//  SingleAssignmentDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class SingleAssignmentDisposable : DisposeBase, Disposable, Cancelable {
    var lock = SpinLock()
    // state
    var _disposed = false
    var _disposableSet = false
    var _disposable = nil as Disposable?

    public var disposed: Bool {
        get {
            return lock.calculateLocked {
                return _disposed
            }
        }
    }

    public override init() {
        super.init()
    }

    public var disposable: Disposable {
        get {
            return lock.calculateLocked {
                return _disposable ?? NopDisposable.instance
            }
        }
        set {
            let disposable: Disposable? = lock.calculateLocked {
                if _disposableSet {
                    rxFatalError("oldState.disposable != nil")
                }

                _disposableSet = true

                if _disposed {
                    return newValue
                }

                _disposable = newValue

                return nil
            }

            if let disposable = disposable {
                disposable.dispose()
            }
        }
    }

    public func dispose() {
        let disposable: Disposable? = lock.calculateLocked {
            _disposed = true
            let dispose = _disposable
            _disposable = nil

            return dispose
        }

        if let disposable = disposable {
            disposable.dispose()
        }
    }
}
