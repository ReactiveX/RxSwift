//
//  CompositeDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents a group of disposable resources that are disposed together.
*/
public class CompositeDisposable : DisposeBase, Disposable, Cancelable {
    public typealias DisposeKey = Bag<Disposable>.KeyType
    
    private var _lock = SpinLock()
    
    // state
    private var _disposables: Bag<Disposable>? = Bag()

    public var disposed: Bool {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables == nil
    }
    
    public override init() {
    }
    
    /**
     Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public init(_ disposable1: Disposable, _ disposable2: Disposable) {
        // This overload is here to make sure we are using optimized version up to 4 arguments.
        let _ = _disposables!.insert(disposable1)
        let _ = _disposables!.insert(disposable2)
    }
    
    /**
     Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {
        // This overload is here to make sure we are using optimized version up to 4 arguments.
        let _ = _disposables!.insert(disposable1)
        let _ = _disposables!.insert(disposable2)
        let _ = _disposables!.insert(disposable3)
    }
    
    /**
     Initializes a new instance of composite disposable with the specified number of disposables.
     */
    public init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable, _ disposable4: Disposable, _ disposables: Disposable...) {
        // This overload is here to make sure we are using optimized version up to 4 arguments.
        let _ = _disposables!.insert(disposable1)
        let _ = _disposables!.insert(disposable2)
        let _ = _disposables!.insert(disposable3)
        let _ = _disposables!.insert(disposable4)
        
        for disposable in disposables {
            let _ = _disposables!.insert(disposable)
        }
    }
    
    /**
     Initializes a new instance of composite disposable with the specified number of disposables.
    */
    public init(disposables: [Disposable]) {
        for disposable in disposables {
            let _ = _disposables!.insert(disposable)
        }
    }

    /**
    Adds a disposable to the CompositeDisposable or disposes the disposable if the CompositeDisposable is disposed.
    
    - parameter disposable: Disposable to add.
    - returns: Key that can be used to remove disposable from composite disposable. In case dispose bag was already
        disposed `nil` will be returned.
    */
    public func addDisposable(_ disposable: Disposable) -> DisposeKey? {
        let key = _addDisposable(disposable)

        if key == nil {
            disposable.dispose()
        }
        
        return key
    }

    private func _addDisposable(_ disposable: Disposable) -> DisposeKey? {
        _lock.lock(); defer { _lock.unlock() }

        return _disposables?.insert(disposable)
    }
    
    /**
    - returns: Gets the number of disposables contained in the `CompositeDisposable`.
    */
    public var count: Int {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables?.count ?? 0
    }
    
    /**
    Removes and disposes the disposable identified by `disposeKey` from the CompositeDisposable.
    
    - parameter disposeKey: Key used to identify disposable to be removed.
    */
    public func removeDisposable(_ disposeKey: DisposeKey) {
        _removeDisposable(disposeKey)?.dispose()
    }

    private func _removeDisposable(_ disposeKey: DisposeKey) -> Disposable? {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables?.removeKey(disposeKey)
    }
    
    /**
    Disposes all disposables in the group and removes them from the group.
    */
    public func dispose() {
        if let disposables = _dispose() {
            disposeAllIn(disposables)
        }
    }

    private func _dispose() -> Bag<Disposable>? {
        _lock.lock(); defer { _lock.unlock() }

        let disposeBag = _disposables
        _disposables = nil

        return disposeBag
    }
}
