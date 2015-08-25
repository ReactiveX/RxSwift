//
//  CompositeDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class CompositeDisposable : DisposeBase, Disposable, Cancelable {
    public typealias DisposeKey = Bag<Disposable>.KeyType
    
    var lock = SpinLock()
    var disposables: Bag<Disposable>? = Bag()

    public var disposed: Bool {
        get {
            return self.lock.calculateLocked {
                return disposables == nil
            }
        }
    }
    
    public override init() {
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable) {
        self.disposables!.put(disposable1)
        self.disposables!.put(disposable2)
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {
        disposables!.put(disposable1)
        disposables!.put(disposable2)
        disposables!.put(disposable3)
    }
    
    public init(disposables: [Disposable]) {
        for disposable in disposables {
            self.disposables!.put(disposable)
        }
    }
    
    public func addDisposable(disposable: Disposable) -> DisposeKey? {
        // this should be let
        // bucause of compiler bug it's var
        let key  = self.lock.calculateLocked { () -> DisposeKey? in
            return disposables?.put(disposable)
        }
        
        if key == nil {
            disposable.dispose()
        }
        
        return key
    }
    
    public var count: Int {
        get {
            return self.lock.calculateLocked {
                return disposables?.count ?? 0
            }
        }
    }
    
    public func removeDisposable(disposeKey: DisposeKey) {
        let disposable = self.lock.calculateLocked { () -> Disposable? in
            return disposables?.removeKey(disposeKey)
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
    
    public func dispose() {
        let oldDisposables = self.lock.calculateLocked { () -> Bag<Disposable>? in
            let disposeBag = disposables
            self.disposables = nil
            
            return disposeBag
        }
        
        if let oldDisposables = oldDisposables {
            oldDisposables.forEach { d in
                d.dispose()
            }
        }
    }
}