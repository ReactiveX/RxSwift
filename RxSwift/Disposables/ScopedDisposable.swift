//
//  ScopedDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Disposable {
    /**
    Returns `ScopedDispose` that will dispose `self` when execution exits current block.
    
    **If the reference to returned instance isn't named, it will be deallocated 
    immediately and subscription will be immediately disposed.**
    
    Example usage:
    
        let disposeOnExit = disposable.scopedDispose()
    
    - returns: `ScopedDisposable` that will dispose `self` on `deinit`.
    */
    public func scopedDispose() -> ScopedDisposable {
        return ScopedDisposable(disposable: self)
    }
}


/**
`ScopedDisposable` will dispose `disposable` on `deinit`.

This returns ARC (RAII) like resource management to `RxSwift`.
*/
public class ScopedDisposable : DisposeBase {
    private var _disposable: Disposable?
    
    /**
    Initializes new instance with a single disposable.
    
    - parameter disposable: `Disposable` that will be disposed on scope exit.
    */
    public init(disposable: Disposable) {
        _disposable = disposable
    }
    
    /**
    This is intentionally private.
    */
    func dispose() {
        _disposable?.dispose()
    }
    
    deinit {
        dispose()
    }
}