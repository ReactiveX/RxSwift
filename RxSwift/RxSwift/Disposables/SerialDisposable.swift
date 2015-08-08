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
    
    var lock = SpinLock()
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
    
    var disposable: Disposable {
        get {
            return self.lock.calculateLocked {
                return self.disposable
            }
        }
        set (newDisposable) {
            let disposable: Disposable? = self.lock.calculateLocked {
                if state.disposed {
                    return newDisposable
                }
                else {
                    let toDispose = state.current
                    state.current = newDisposable
                    return toDispose
                }
            }
            
            if let disposable = disposable {
                disposable.dispose()
            }
        }
    }
    
    public func dispose() {
        let disposable: Disposable? = self.lock.calculateLocked {
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