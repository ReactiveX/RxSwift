//
//  NAryDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class NAryDisposable : DisposeBase, Cancelable {
    
    var disposables: [Disposable]?
    
    var _disposed: Int32 = 0
    
    var disposed: Bool {
        get {
            return _disposed > 0
        }
    }
    
    init(_ disposables: [Disposable]) {
        self.disposables = disposables
        super.init()
    }
    
    func dispose() {
        if OSAtomicCompareAndSwap32(0, 1, &_disposed) {
            for disposable in disposables! {
                disposable.dispose()
            }
            disposables = nil
        }
    }
}