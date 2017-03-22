//
//  AnyVariable.swift
//  RxSwift
//
//  Created by Yasuhiro Inami on 2/28/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

/// A get-only `Variable`.
public final class AnyVariable<Element>: ObservableConvertibleType {

    public typealias E = Element

    let _variable: Variable<E>

    /// Gets current value of variable.
    public var value: E {
        get {
            return _variable.value
        }
    }

    /// Initializes variable with initial value.
    ///
    /// - parameter value: Initial variable value.
    public init(_ value: E) {
        _variable = Variable(value)
    }

    /// Initializes variable with `Variable`.
    ///
    /// - parameter value: Initial `Variable`.
    public init(_ variable: Variable<E>) {
        _variable = variable
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<E> {
        return _variable.asObservable()
    }

}
