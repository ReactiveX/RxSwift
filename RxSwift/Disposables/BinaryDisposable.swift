//
//  BinaryDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents two disposable resources that are disposed together.
*/
public final class BinaryDisposable : DisposeBase, Cancelable {
    
    private var _disposed: Int32 = 0

    // state
    private var disposable1: Disposable?
    private var disposable2: Disposable?
    
    /**
    - returns: Was resource disposed.
    */
    public var disposed: Bool {
        get {
            return _disposed > 0
        }
    }
    
    /**
    Constructs new binary disposable from two disposables.
    
    - parameter disposable1: First disposable
    - parameter disposable2: Second disposable
    */
    init(_ disposable1: Disposable, _ disposable2: Disposable) {
        self.disposable1 = disposable1
        self.disposable2 = disposable2
        super.init()
    }
    
    /**
    Calls the disposal action if and only if the current instance hasn't been disposed yet.
    
    After invoking disposal action, disposal action will be dereferenced.
    */
    public func dispose() {
        if OSAtomicCompareAndSwap32(0, 1, &_disposed) {
            disposable1?.dispose()
            disposable2?.dispose()
            disposable1 = nil
            disposable2 = nil
        }
    }
}