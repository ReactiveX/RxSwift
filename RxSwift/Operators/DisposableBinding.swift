//
//  DisposableBinding.swift
//  RxSwift
//
//  Created by Sebastián Varela Basconi on 11/10/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

public protocol DisposableContainer {
    associatedtype AnyDisposableReturnType

    func insert(_ disposable: Disposable) -> AnyDisposableReturnType
}

extension DisposeBag: DisposableContainer {
    public typealias AnyDisposableReturnType = Void
}

extension CompositeDisposable: DisposableContainer {
    public typealias AnyDisposableReturnType = DisposeKey?
}

// Append Disposable
precedencegroup DisposableBindingPrecedence {
    associativity: left
    lowerThan: DefaultPrecedence
    higherThan: RangeFormationPrecedence
}

infix operator ~~> : DisposableBindingPrecedence
infix operator <~~ : DisposableBindingPrecedence

/**
 Bind a disposable to another disposable collection (CompositeDisposable or DisposeBag)
 
 - parameter disposable: A disposable to be binded.
 - parameter collection: Disposable collection.
 - returns: disposable collection.
 */
@discardableResult
public func <~~ <T: DisposableContainer>(container: T, disposable: Disposable) -> T {
    _ = container.insert(disposable)
    return container
}

@discardableResult
public func ~~> <T: DisposableContainer>(disposable: Disposable, container: T) -> T {
    return container <~~ disposable
}

