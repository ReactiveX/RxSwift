//
//  DisposeBag.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Disposable {
    public func addDisposableTo(bag: DisposeBag) {
        bag.addDisposable(self)
    }
}

// Thread safe bag that disposes disposables that have been added to it on `deinit`.
// This returns ARC (RAII) like resource management to `RxSwift`.
public class DisposeBag: DisposeBase {
    
    private var lock = SpinLock()
    var disposables = [Disposable]()
    var disposed = false
    
    public override init() {
        super.init()
    }
    
    public func addDisposable(disposable: Disposable) {
        let dispose = lock.calculateLocked { () -> Bool in
            if disposed {
                return true
            }
            
            disposables.append(disposable)
            
            return false
        }
        
        if dispose {
            disposable.dispose()
        }
    }

    func dispose() {
        let oldDisposables = lock.calculateLocked { () -> [Disposable] in
            let disposables = self.disposables
            
            self.disposables.removeAll(keepCapacity: false)
            self.disposed = true
            
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