//
//  CompositeDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class CompositeDisposable : DisposeBase, Disposable {
    public typealias BagKey = Bag<Disposable>.KeyType
    
    typealias State = (
        disposables: MutatingBox<Bag<Disposable>>!,
        disposed: Bool
    )
    
    var lock: Lock = Lock()
    var state: State = (
        disposables: MutatingBox(Bag()),
        disposed: false
    )
    
    public override init() {
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable) {
        let bag = state.disposables
        
        bag.value.put(disposable1)
        bag.value.put(disposable2)
    }
    
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {
        let bag = state.disposables
        
        bag.value.put(disposable1)
        bag.value.put(disposable2)
        bag.value.put(disposable3)
    }
    
    public init(disposables: [Disposable]) {
        let bag = state.disposables
        
        for disposable in disposables {
            bag.value.put(disposable)
        }
    }
    
    public func addDisposable(disposable: Disposable) -> BagKey? {
        // this should be let
        // bucause of compiler bug it's var
        let key  = self.lock.calculateLocked { oldState -> BagKey? in
            if state.disposed {
                return nil
            }
            else {
                let key = state.disposables.value.put(disposable)
                return key
            }
        }
        
        if key == nil {
            disposable.dispose()
        }
        
        return key
    }
    
    public var count: Int {
        get {
            return self.lock.calculateLocked {
                self.state.disposables.value.count
            }
        }
    }
    
    public func removeDisposable(disposeKey: BagKey) {
        let disposable = self.lock.calculateLocked { Void -> Disposable? in
            return state.disposables.value.removeKey(disposeKey)
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
    
    public func dispose() {
        let oldDisposables = self.lock.calculateLocked { Void -> [Disposable] in
            if state.disposed {
                return []
            }
            
            let disposables = state.disposables
            var allValues = disposables.value.all
            
            state.disposed = true
            state.disposables = nil
            
            return allValues
        }
        
        for d in oldDisposables {
            d.dispose()
        }
    }
}