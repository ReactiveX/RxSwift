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
    var disposables: RxMutableBox<Bag<Disposable>>? = RxMutableBox(Bag())
    
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
        if let disposables = self.disposables {
            disposables.value.put(disposable1)
            disposables.value.put(disposable2)
        }
        else {
            rxFatalError("Bag should exist")
        }
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {
        if let disposables = self.disposables {
            disposables.value.put(disposable1)
            disposables.value.put(disposable2)
            disposables.value.put(disposable3)
        }
        else {
            rxFatalError("Bag should exist")
        }
    }
    
    public init(disposables: [Disposable]) {
        if let disposablesBox = self.disposables {
            for disposable in disposables {
                disposablesBox.value.put(disposable)
            }
        }
        else {
            rxFatalError("Bag should exist")
        }
    }
    
    public func addDisposable(disposable: Disposable) -> DisposeKey? {
        // this should be let
        // bucause of compiler bug it's var
        let key  = self.lock.calculateLocked { () -> DisposeKey? in
            return disposables?.value.put(disposable)
        }
        
        if key == nil {
            disposable.dispose()
        }
        
        return key
    }
    
    public var count: Int {
        get {
            return self.lock.calculateLocked {
                return disposables?.value.count ?? 0
            }
        }
    }
    
    public func removeDisposable(disposeKey: DisposeKey) {
        let disposable = self.lock.calculateLocked { () -> Disposable? in
            return disposables?.value.removeKey(disposeKey)
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
    
    public func dispose() {
        let oldDisposables = self.lock.calculateLocked { () -> [Disposable]? in
            let allDisposables = disposables?.value.all
            self.disposables = nil
            
            return allDisposables
        }
        
        if let oldDisposables = oldDisposables {
            for d in oldDisposables {
                d.dispose()
            }
        }
    }
}