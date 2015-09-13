//
//  SingleAssignmentDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents a disposable resource which only allows a single assignment of its underlying disposable resource.

If an underlying disposable resource has already been set, future attempts to set the underlying disposable resource will throw an exception.
*/
public class SingleAssignmentDisposable : DisposeBase, Disposable, Cancelable {
    private var lock = SpinLock()
    
    // state
    private var _disposed = false
    private var _disposableSet = false
    private var _disposable = nil as Disposable?

    /**
    - returns: A value that indicates whether the object is disposed.
    */
    public var disposed: Bool {
        get {
            return lock.calculateLocked {
                return _disposed
            }
        }
    }

    /**
    Initializes a new instance of the `SingleAssignmentDisposable`.
    */
    public override init() {
        super.init()
    }

    /**
    Gets or sets the underlying disposable. After disposal, the result of getting this property is undefined.
    
    **Throws exception if the `SingleAssignmentDisposable` has already been assigned to.**
    */
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

    /**
    Disposes the underlying disposable.
    */
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
