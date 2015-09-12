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
    
    private let lock = SpinLock()
    private var current: Disposable?
    
    /**
    - returns: Was resource disposed.
    */
    public private(set) var disposed = false
    
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
        set {
            lock.calculateLocked { () -> Disposable? in
                if disposed {
                    return newValue
                } else {
                    let toDispose = current
                    current = newValue
                    return toDispose
                } }?
                
                .dispose()
        }
    }
    
    /**
    Disposes the underlying disposable as well as all future replacements.
    */
    public func dispose() {
        
        lock.calculateLocked { () -> Disposable? in
            if disposed {
                return nil
            } else {
                disposed = true
                return current
            } }?
            
            .dispose()
    }
}