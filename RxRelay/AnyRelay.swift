//
//  AnyRelay.swift
//  RxRelay
//
//  Created by Anton Nazarov on 17/07/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

/// A type-erased `RelayType`.
///
/// Forwards operations to an arbitrary underlying relay with the same `Element` type, hiding the specifics of the underlying relay type.
public struct AnyRelay<Element>: RelayType {
    /// Anonymous element handler type.
    public typealias ElementHandler = (Element) -> Void

    private let relay: ElementHandler

    /// Construct an instance whose `accept(element)` calls `elementHandler(element)`
    ///
    /// - parameter elementHandler: Element handler that observes sequences elements.
    public init(elementHandler: @escaping ElementHandler) {
        self.relay = elementHandler
    }

    /// Construct an instance whose `accept(element)` calls `relay.accept(element)`
    ///
    /// - parameter relay: Relay that receives sequence elements.
    public init<Relay: RelayType>(_ relay: Relay) where Relay.Element == Element {
        self.relay = relay.accept
    }

    /// Send `element` to this relay.
    ///
    /// - parameter element: Element instance.
    public func accept(_ element: Element) {
        return self.relay(element)
    }

    /// Erases type of relay and returns canonical relay.
    ///
    /// - returns: type erased relay.
    public func asRelay() -> AnyRelay<Element> {
        return self
    }
}

extension RelayType {
    /// Erases type of relay and returns canonical relay.
    ///
    /// - returns: type erased relay.
    public func asRelay() -> AnyRelay<Element> {
        return AnyRelay(self)
    }
}
