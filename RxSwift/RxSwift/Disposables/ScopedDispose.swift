//
//  ScopedDispose.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// It will dispose `disposable` on `deinit`.
// This returns ARC (RAII) like resource management to `RxSwift`.
public class ScopedDispose : DisposeBase {
    var disposable: Disposable?
    
    public init(disposable: Disposable) {
        self.disposable = disposable
    }
    
    func dispose() {
        // disposables are already thread safe
        self.disposable?.dispose()
    }
    
    deinit {
        self.dispose()
    }
}

public func scopedDispose(disposable: Disposable) -> ScopedDispose {
    return ScopedDispose(disposable: disposable)
}