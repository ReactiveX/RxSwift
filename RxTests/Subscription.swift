//
//  Subscription.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct Subscription
    : Equatable
    , Hashable
    , CustomDebugStringConvertible {

    public let subscribe : Int
    public let unsubscribe : Int
    
    public init(_ subscribe: Int) {
        self.subscribe = subscribe
        self.unsubscribe = Int.max
    }
    
    public init(_ subscribe: Int, _ unsubscribe: Int) {
        self.subscribe = subscribe
        self.unsubscribe = unsubscribe
    }
    
    public var hashValue : Int {
        get {
            return subscribe.hashValue ^ unsubscribe.hashValue
        }
    }
}

extension Subscription {
    public var debugDescription : String {
        get {
            let infiniteText = "Infinity"
            return "(\(subscribe) : \(unsubscribe != Int.max ? String(unsubscribe) : infiniteText))"
        }
    }
}

public func == (lhs: Subscription, rhs: Subscription) -> Bool {
    return lhs.subscribe == rhs.subscribe && lhs.unsubscribe == rhs.unsubscribe
}