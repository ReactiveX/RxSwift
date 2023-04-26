//
//  BooleanDisposable.swift
//  RxSwift
//
//  Created by Junior B. on 10/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a disposable resource that can be checked for disposal status.
public final class BooleanDisposable : Cancelable {

    internal static let BooleanDisposableTrue = BooleanDisposable(isDisposed: true)
    private let disposed: AtomicInt
    
    /// Initializes a new instance of the `BooleanDisposable` class
    public init() {
        disposed = AtomicInt(0)
    }
    
    /// Initializes a new instance of the `BooleanDisposable` class with given value
    public init(isDisposed: Bool) {
        self.disposed = AtomicInt(isDisposed ? 1 : 0)
    }
    
    /// - returns: Was resource disposed.
    public var isDisposed: Bool {
        isFlagSet(self.disposed, 1)
    }
    
    /// Sets the status to disposed, which can be observer through the `isDisposed` property.
    public func dispose() {
        fetchOr(self.disposed, 1)
    }
}
