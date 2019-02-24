//
//  AnyObserver.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


/// A type-erased `ObserverType`.
///
/// Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying observer type.
@available(*, deprecated, message: "Please use ObservableSource<Element, Completed, Error>.Observer instead.")
public struct AnyObserver<ElementType> : ObserverType {
    public typealias Element = ElementType
    public typealias Completed = ()
    public typealias Error = Swift.Error
    
    private let observer: ObservableSource<Element, Completed, Error>.Observer

    /// Construct an instance whose `on(event)` calls `eventHandler(event)`
    ///
    /// - parameter eventHandler: Event handler that observes sequences events.
    public init(eventHandler: @escaping ObservableSource<Element, Completed, Error>.Observer) {
        self.observer = eventHandler
    }
    
    /// Construct an instance whose `on(event)` calls `observer.on(event)`
    ///
    /// - parameter observer: Observer that receives sequence events.
    public init(_ observer: @escaping ObservableSource<Element, Completed, Error>.Observer) {
        self.observer = observer
    }
    
    /// Send `event` to this observer.
    ///
    /// - parameter event: Event instance.
    public func on(_ event: Event<Element, Completed, Error>) {
        return self.observer(event)
    }

    /// Erases type of observer and returns canonical observer.
    ///
    /// - returns: type erased observer.
    public func asObserver() -> AnyObserver<Element> {
        return self
    }
}

