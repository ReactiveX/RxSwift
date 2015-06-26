//
//  TernaryDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TernaryDisposable : DisposeBase, Cancelable {
    var disposable1: Disposable?
    var disposable2: Disposable?
    var disposable3: Disposable?
    
    var _disposed: Int32 = 0
    
    var disposed: Bool {
        get {
            return _disposed > 0
        }
    }
    
    init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {
        self.disposable1 = disposable1
        self.disposable2 = disposable2
        self.disposable3 = disposable3
        super.init()
    }
    
    func dispose() {
        if OSAtomicCompareAndSwap32(0, 1, &_disposed) {
            disposable1?.dispose()
            disposable2?.dispose()
            disposable3?.dispose()
            disposable1 = nil
            disposable2 = nil
            disposable3 = nil
        }
    }
}