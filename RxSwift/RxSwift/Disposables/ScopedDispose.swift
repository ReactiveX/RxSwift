//
//  ScopedDispose.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Disposable {
    public var scopedDispose: ScopedDispose {
        return ScopedDispose(disposable: self)
    }
}


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