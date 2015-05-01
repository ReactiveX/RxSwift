//
//  ObserverBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ObserverBase<ElementType> : ObserverType, Disposable {
    typealias Element = ElementType
    
    var lock = Lock()
    var isStopped: Bool = false
    
    public init() {
    }
    
    public func on(event: Event<Element>) {
        switch event {
        case .Next:
            if !isStopped {
                onCore(event)
            }
        case .Error: fallthrough
        case .Completed:
            var wasStopped: Bool = lock.calculateLocked {
                var wasStopped = self.isStopped
                self.isStopped = true
                return wasStopped
            }
            
            if !wasStopped {
                self.onCore(event)
            }
        }
    }
    
    public func onCore(event: Event<Element>) {
    }
    
    public func dispose() {
    }
}