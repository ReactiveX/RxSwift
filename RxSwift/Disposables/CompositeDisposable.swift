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
public class CompositeDisposable : DisposeBase, Cancelable {
    
    public typealias DisposeKey = Bag<Disposable>.KeyType
    
    private let lock = SpinLock()
    private var disposables = Bag<Disposable>?()
    
    public var disposed: Bool {
        return lock.calculateLocked {
            disposables == nil
        }
    }
    
    /**
    Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public init(disposables: [Disposable]) {
        for aDisposable in disposables {
            self.disposables!.insert(aDisposable)
        }
    }
    
    /**
    Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public convenience init(_ disposables: Disposable...) {
        self.init(disposables: disposables)
    }
    
    /**
    Adds a disposable to the CompositeDisposable or disposes the disposable if the CompositeDisposable is disposed.
    
    - parameter disposable: Disposable to add.
    - returns: Key that can be used to remove disposable from composite disposable. In case dispose bag was already disposed `nil` will be returned.
    */
    public func addDisposable(disposable: Disposable) -> DisposeKey? {
        if let key = lock.calculateLocked({ disposables?.insert(disposable) }) {
            return key
        } else {
            disposable.dispose()
            return nil
        }
    }
    
    /**
    - returns: Gets the number of disposables contained in the `CompositeDisposable`.
    */
    public var count: Int {
        return lock.calculateLocked {
            disposables?.count ?? 0
        }
    }
    
    /**
    Removes and disposes the disposable identified by `disposeKey` from the CompositeDisposable.
    
    - parameter disposeKey: Key used to identify disposable to be removed.
    */
    public func removeDisposable(disposeKey: DisposeKey) {
        lock.calculateLocked { disposables?.removeKey(disposeKey) }?
            .dispose()
    }
    
    /**
    Disposes all disposables in the group and removes them from the group.
    */
    public func dispose() {
        lock.calculateLocked { () -> Bag<Disposable>? in
            
            let disposeBag = disposables
            disposables = nil
            return disposeBag }?
            
            .forEach { $0.dispose() }
    }
}