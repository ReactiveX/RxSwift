//
//  AnonymousDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class AnonymousDisposable : DisposeBase, Cancelable {
    public typealias DisposeAction = () -> Void
    
    var lock = SpinLock()
    var disposeAction: DisposeAction?
    
    public var disposed: Bool {
        get {
            return lock.calculateLocked {
                return self.disposeAction == nil
            }
        }
    }
    
    public init(_ disposeAction: DisposeAction) {
        self.disposeAction = disposeAction
        super.init()
    }

    public func dispose() {
        let toDispose: DisposeAction? = lock.calculateLocked {
            let action = self.disposeAction
            self.disposeAction = nil
            return action
        }
        
        if let toDispose = toDispose {
            toDispose()
        }
    }
}