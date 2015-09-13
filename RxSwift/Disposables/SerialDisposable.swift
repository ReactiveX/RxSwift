//
//  SerialDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents a disposable resource whose underlying disposable resource can be replaced by another disposable resource, causing automatic disposal of the previous underlying disposable resource.
*/
public class SerialDisposable : DisposeBase, Cancelable {
    var lock = SpinLock()
    
    // state
    private var _current = nil as Disposable?
    private var _disposed = false
    
    /**
    - returns: Was resource disposed.
    */
    public var disposed: Bool {
        get {
            return _disposed
        }
    }
    
    /**
    Initializes a new instance of the `SerialDisposable`.
    */
    override public init() {
        super.init()
    }
    
    /**
    Gets or sets the underlying disposable.
    
    Assigning this property disposes the previous disposable object.
    
    If the `SerialDisposable` has already been disposed, assignment to this property causes immediate disposal of the given disposable object.
    */
    public var disposable: Disposable {
        get {
            return self.lock.calculateLocked {
                return self.disposable
            }
        }
        set (newDisposable) {
            let disposable: Disposable? = self.lock.calculateLocked {
                if _disposed {
                    return newDisposable
                }
                else {
                    let toDispose = _current
                    _current = newDisposable
                    return toDispose
                }
            }
            
            if let disposable = disposable {
                disposable.dispose()
            }
        }
    }
    
    /**
    Disposes the underlying disposable as well as all future replacements.
    */
    public func dispose() {
        let disposable: Disposable? = self.lock.calculateLocked {
            if _disposed {
                return nil
            }
            else {
                _disposed = true
                return _current
            }
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
}