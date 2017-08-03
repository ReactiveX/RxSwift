//
//  ObserverType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Supports push-style iteration over an observable sequence.
public protocol ObserverType {
    /// The type of elements in sequence that observer can observe.
    associatedtype E

    /// Notify observer about sequence event.
    ///
    /// - parameter event: Event that occurred.
    func on(_ event: Event<E>)
}

/// Convenience API extensions to provide alternate next, error, completed events
extension ObserverType {
    
    /// Convenience method equivalent to `on(.next(element: E))`
    ///
    /// - parameter element: Next element to send to observer(s)
    #if swift(>=3.2)
    public func onNext(_ element: E) {
        on(.next(element))
    }
    #else
    public final func onNext(_ element: E) {
        on(.next(element))
    }
    #endif
    
    /// Convenience method equivalent to `on(.completed)`
    #if swift(>=3.2)
    public func onCompleted() {
        on(.completed)
    }
    #else
    public final func onCompleted() {
        on(.completed)
    }
    #endif
    
    /// Convenience method equivalent to `on(.error(Swift.Error))`
    /// - parameter error: Swift.Error to send to observer(s)
    #if swift(>=3.2)
    public func onError(_ error: Swift.Error) {
        on(.error(error))
    }
    #else
    public final func onError(_ error: Swift.Error) {
        on(.error(error))
    }
    #endif
}
