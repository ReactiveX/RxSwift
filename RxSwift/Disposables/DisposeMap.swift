//
//  DisposeMap.swift
//  RxSwift
//
//  Created by Anatoly Shcherbinin on 4/10/20.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

extension Disposable {
    /// Adds `self` to `bag`
    ///
    /// - parameter map: `DisposeMap` to add `self` to.
    public func disposed<T>(by map: DisposeMap<T>, key: T) {
        map.insert(self, forKey: key)
    }

    public func disposed(by map: DisposeMap<Int>, key: Int = #line) {
        map.insert(self, forKey: key)
    }

}

/**
 Thread safe map, that disposes duplicating disposables
 */
public final class DisposeMap<T:Hashable>: DisposeBase {

    private let _lock = SpinLock()

    // state
    private var _disposables = [T:Disposable]()
    private var _isDisposed = false

    /// Constructs new empty dispose map.
    public override init() {
        super.init()
    }

    /// Adds `disposable` to be disposed when dispose bag is being deinited
    /// or when other disposable with same key is added
    ///
    /// - parameter disposable: Disposable to add.
    /// - parameter key: comparison key
    public func insert(_ disposable: Disposable, forKey key: T) {
        self._insert(disposable, forKey: key)?.dispose()
    }

    private func _insert(_ disposable: Disposable, forKey key: T) -> Disposable? {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isDisposed {
            return disposable
        }

        let oldDisposable = _disposables[key]
        _disposables[key] = disposable
        return oldDisposable
    }

    /// This is internal on purpose, take a look at `CompositeDisposable` instead.
    private func dispose() {
        let oldDisposables = self._dispose()

        for disposable in oldDisposables {
            disposable.dispose()
        }
    }

    private func _dispose() -> [Disposable] {
        self._lock.lock(); defer { self._lock.unlock() }

        let disposables = self._disposables.values

        self._disposables.removeAll(keepingCapacity: false)
        self._isDisposed = true

        return [Disposable](disposables)
    }

    deinit {
        self.dispose()
    }
}
