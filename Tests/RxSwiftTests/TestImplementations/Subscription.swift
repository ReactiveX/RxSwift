//
//  Subscription.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct Subscription
    : Equatable
    , Hashable
    , CustomDebugStringConvertible {

    let subscribe : Time
    let unsubscribe : Time
    
    init(_ subscribe: Time) {
        self.subscribe = subscribe
        self.unsubscribe = Int.max
    }
    
    init(_ subscribe: Time, _ unsubscribe: Time) {
        self.subscribe = subscribe
        self.unsubscribe = unsubscribe
    }
    
    var hashValue : Int {
        get {
            return subscribe.hashValue ^ unsubscribe.hashValue
        }
    }
}

extension Subscription {
    var debugDescription : String {
        get {
            let infiniteText = "Infinity"
            return "(\(subscribe) : \(unsubscribe != Time.max ? String(unsubscribe) : infiniteText))"
        }
    }
}

func == (lhs: Subscription, rhs: Subscription) -> Bool {
    return lhs.subscribe == rhs.subscribe && lhs.unsubscribe == rhs.unsubscribe
}