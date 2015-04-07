//
//  DisposeBag.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class DisposeBag: DisposeBase, Disposable {
    private var lock = Lock()
    
    private var disposables: [Disposable] = []
    
    public override init() {
        super.init()
    }
    
    public func addDisposable(disposable: Disposable) {
        disposables.append(disposable)
    }

    public func addDisposable(disposable: Result<Disposable>) {
        disposables.append(*disposable)
    }
    
    public func dispose() {
        let oldDisposables = lock.calculateLocked { () -> [Disposable] in
            var disposables = self.disposables
            self.disposables.removeAll(keepCapacity: true)
            
            return disposables
        }
        
        for disposable in oldDisposables {
            disposable.dispose()
        }
    }
    
    deinit {
        dispose()
    }
}