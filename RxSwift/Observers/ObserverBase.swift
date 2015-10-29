//
//  ObserverBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ObserverBase<ElementType> : Disposable, ObserverType {
    typealias E = ElementType
    
    private var _isStopped: Int32 = 0
    
    func on(event: Event<E>) {
        switch event {
        case .Next:
            if _isStopped == 0 {
                onCore(event)
            }
        case .Error, .Completed:
           
            if !OSAtomicCompareAndSwap32(0, 1, &_isStopped) {
                return
            }
            
            onCore(event)
        }
    }
    
    func onCore(event: Event<E>) {
        abstractMethod()
    }
    
    func dispose() {
        _isStopped = 1
    }
}