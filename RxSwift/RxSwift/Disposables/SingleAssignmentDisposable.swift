//
//  SingleAssignmentDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class SingleAssignmentDisposable : DisposeBase, Disposable, Cancelable {
    typealias State = (
        disposed: Bool,
        disposableSet: Bool,
        disposable: Disposable?
    )
    
    var lock = Lock()
    var state: State = (
        disposed: false,
        disposableSet: false,
        disposable: nil
    )
    
    public var disposed: Bool {
        get {
            return lock.calculateLocked {
                return state.disposed
            }
        }
    }
    
    public override init() {
        super.init()
    }

    public var disposable: Disposable {
        get {
            return lock.calculateLocked {
                return self.state.disposable ?? NopDisposable.instance
            }
        }
        set(newDisposable) {
            var disposable: Disposable? = lock.calculateLocked { oldState in
                
                if state.disposableSet {
                    rxFatalError("oldState.disposable != nil")
                }
                
                state.disposableSet = true
                
                if state.disposed {
                    return newDisposable
                }
                
                state.disposable = newDisposable
                
                return nil
            }
            
            if let disposable = disposable {
                return disposable.dispose()
            }
        }
    }
    
    public func dispose() {
        var disposable: Disposable? = lock.calculateLocked { old in
            state.disposed = true
            var dispose = state.disposable
            state.disposable = nil
            
            return dispose
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
}