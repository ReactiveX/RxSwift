//
//  SerialDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class SerialDisposable : DisposeBase, Cancelable {
    typealias State = (
        current: Disposable?,
        disposed: Bool
    )
    
    var lock = Lock()
    var state: State = (
        current: nil,
        disposed: false
    )
    
    public var disposed: Bool {
        get {
            return state.disposed
        }
    }
    
    override public init() {
        super.init()
    }
    
    public func setDisposable(disposable: Disposable) {
        var disposable: Disposable? = self.lock.calculateLocked {
            if state.disposed {
                return disposable
            }
            else {
                var toDispose = state.current
                state.current = disposable
                return toDispose
            }
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
    
    public func dispose() {
        var disposable: Disposable? = self.lock.calculateLocked {
            if state.disposed {
                return nil
            }
            else {
                state.disposed = true
                return state.current
            }
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
}