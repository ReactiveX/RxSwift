//
//  AnonymousDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents an Action-based disposable.

When dispose method is called, disposal action will be dereferenced.
*/
public final class AnonymousDisposable : DisposeBase, Cancelable {
    
    public typealias DisposeAction = () -> Void
    
    private let lock = SpinLock()
    private var disposeAction: DisposeAction?
    
    /**
    - returns: Was resource disposed.
    */
    public var disposed: Bool {
        return lock.calculateLocked {
            disposeAction == nil
        }
    }
    
    /**
    Constructs a new disposable with the given action used for disposal.
    
    - parameter disposeAction: Disposal action which will be run upon calling `dispose`.
    */
    public init(_ disposeAction: DisposeAction) {
        self.disposeAction = disposeAction
    }
    
    /**
    Calls the disposal action if and only if the current instance hasn't been disposed yet.
    
    After invoking disposal action, disposal action will be dereferenced.
    */
    public func dispose() {
        lock.calculateLocked { () -> DisposeAction? in
            
            let action = disposeAction
            disposeAction = nil
            return action
            
            }?()
    }
}