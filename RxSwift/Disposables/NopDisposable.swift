//
//  NopDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a disposable that does nothing on disposal.
///
/// Nop = No Operation
fileprivate class NopDisposable : Disposable {
 
    fileprivate static let noOp: Disposable = NopDisposable()
    
    fileprivate override init() {
        super.init()
        // Should not count NopDisposable
        #if TRACE_RESOURCES
            let _ = Resources.decrementTotal()
        #endif
    }
    
    /// Does nothing.
    public override func dispose() {
    }
}

extension Disposable {
    /**
     Creates a disposable that does nothing on disposal.
     */
    static public func create() -> Disposable {
        return NopDisposable.noOp
    }
}
