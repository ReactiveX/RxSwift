//
//  Delegate.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

// This should be only used from `MainScheduler`
// 
// Also, please take a look at `RxDelegateBridge` protocol implementation
public class Delegate : NSObject, Disposable {
    private var retainSelf: Delegate! = nil
    
    public var isDisposable: Bool {
        get {
            return true
        }
    }
    
    override init() {
        MainScheduler.ensureExecutingOnScheduler()
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        super.init()
        self.retainSelf = self
    }
    
    func disposeIfNecessary() {
        if !self.isDisposable {
            return
        }
        
        self.dispose()
    }
    
    public func dispose() {
        MainScheduler.ensureExecutingOnScheduler()
        self.retainSelf = nil
    }
    
    deinit {
#if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
#endif
    }
}