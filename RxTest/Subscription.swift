//
//  Subscription.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Records information about subscriptions to and unsubscriptions from observable sequences.
public struct Subscription
    {

    /// Subscription virtual time.
    public let subscribe : Int
    /// Unsubscription virtual time.
    public let unsubscribe : Int

    /// Creates a new subscription object with the given virtual subscription time.
    ///
    /// - parameter subscribe: Virtual time at which the subscription occurred.
    public init(_ subscribe: Int) {
        self.subscribe = subscribe
        self.unsubscribe = Int.max
    }

    
    /// Creates a new subscription object with the given virtual subscription and unsubscription time.
    ///
    /// - parameter subscribe: Virtual time at which the subscription occurred.
    /// - parameter unsubscribe: Virtual time at which the unsubscription occurred.
    public init(_ subscribe: Int, _ unsubscribe: Int) {
        self.subscribe = subscribe
        self.unsubscribe = unsubscribe
    }
}

extension Subscription
    : Hashable
    , Equatable {
    /// The hash value.
    #if swift(>=4.2)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.subscribe)
        hasher.combine(self.unsubscribe)
    }
    #else
    public var hashValue: Int {
        return self.subscribe.hashValue ^ self.unsubscribe.hashValue
    }
    #endif
}

extension Subscription
    : CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription : String {
        let infiniteText = "Infinity"
        return "(\(self.subscribe): \(self.unsubscribe != Int.max ? String(self.unsubscribe) : infiniteText))"
    }
}

public func == (lhs: Subscription, rhs: Subscription) -> Bool {
    return lhs.subscribe == rhs.subscribe && lhs.unsubscribe == rhs.unsubscribe
}
