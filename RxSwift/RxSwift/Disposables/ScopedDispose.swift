//
//  ScopedDispose.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ScopedDispose : DisposeBase, Disposable {
    var disposable: Disposable?
    
    init(disposable: Disposable) {
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

public func scopedDispose(disposable: Disposable) -> Disposable {
    return ScopedDispose(disposable: disposable)
}