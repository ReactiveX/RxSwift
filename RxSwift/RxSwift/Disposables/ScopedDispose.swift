//
//  ScopedDispose.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ScopedDispose : DisposeBase, Disposable {
    var disposable: Disposable?
    
    public init(disposable: Disposable) {
        self.disposable = disposable
    }
    
    public func dispose() {
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