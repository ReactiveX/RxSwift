//
//  ObserverBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ObserverBase<ElementType> : ObserverClassType, Disposable {
    typealias Element = ElementType
    
    var lock = Lock()
    var isStopped: Bool = false
    
    public init() {
    }
    
    public func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            if !isStopped {
                return onCore(event)
            }
            else {
                return SuccessResult
            }
            //return abstractMethod()
        case .Error: fallthrough
        case .Completed:
            var wasStopped: Bool = lock.calculateLocked {
                var wasStopped = self.isStopped
                self.isStopped = true
                return wasStopped
            }
            
            if !wasStopped {
                return self.onCore(event)
            }
            return SuccessResult
        }
    }
    
    public func onCore(event: Event<Element>) -> Result<Void> {
        return SuccessResult
    }
    
    func fail(error: ErrorType) -> Result<Bool> {
        var wasStopped: Bool = lock.calculateLocked {
            var wasStopped = self.isStopped
            self.isStopped = true
            return wasStopped
        }
        
        if !wasStopped {
            return self.onCore(.Error(error)) >>> {
                success(true)
            }
        }
        else {
            return success(false)
        }
    }
    
    public func dispose() {
    }
}