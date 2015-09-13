//
//  CompositeDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents a group of disposable resources that are disposed together.
*/
public class CompositeDisposable : DisposeBase, Disposable, Cancelable {
    public typealias DisposeKey = Bag<Disposable>.KeyType
    
    private var lock = SpinLock()
    
    // state
    private var disposables: Bag<Disposable>? = Bag()

    public var disposed: Bool {
        get {
            return self.lock.calculateLocked {
                return disposables == nil
            }
        }
    }
    
    public override init() {
    }
    
    /**
     Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public init(_ disposable1: Disposable, _ disposable2: Disposable) {
        self.disposables!.insert(disposable1)
        self.disposables!.insert(disposable2)
    }
    
    /**
     Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {
        disposables!.insert(disposable1)
        disposables!.insert(disposable2)
        disposables!.insert(disposable3)
    }
    
    /**
     Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public init(disposables: [Disposable]) {
        for disposable in disposables {
            self.disposables!.insert(disposable)
        }
    }
    
    /**
    Adds a disposable to the CompositeDisposable or disposes the disposable if the CompositeDisposable is disposed.
    
    - parameter disposable: Disposable to add.
    - returns: Key that can be used to remove disposable from composite disposable. In case dispose bag was already
        disposed `nil` will be returned.
    */
    public func addDisposable(disposable: Disposable) -> DisposeKey? {
        // this should be let
        // bucause of compiler bug it's var
        let key  = self.lock.calculateLocked { () -> DisposeKey? in
            return disposables?.insert(disposable)
        }
        
        if key == nil {
            disposable.dispose()
        }
        
        return key
    }
    
    /**
    - returns: Gets the number of disposables contained in the `CompositeDisposable`.
    */
    public var count: Int {
        get {
            return self.lock.calculateLocked {
                return disposables?.count ?? 0
            }
        }
    }
    
    /**
    Removes and disposes the disposable identified by `disposeKey` from the CompositeDisposable.
    
    - parameter disposeKey: Key used to identify disposable to be removed.
    */
    public func removeDisposable(disposeKey: DisposeKey) {
        let disposable = self.lock.calculateLocked { () -> Disposable? in
            return disposables?.removeKey(disposeKey)
        }
        
        if let disposable = disposable {
            disposable.dispose()
        }
    }
    
    /**
    Disposes all disposables in the group and removes them from the group.
    */
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