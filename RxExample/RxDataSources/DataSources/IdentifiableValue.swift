//
//  IdentifiableValue.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/7/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct IdentifiableValue<Value: Hashable>
    : IdentifiableType
    , Equatable
    , CustomStringConvertible
    , CustomDebugStringConvertible {
    public typealias Identity = Value

    public let value: Value

    public var identity : Identity {
        return value
    }

    public var description: String {
        return "\(value)"
    }

    public var debugDescription: String {
        return "\(value)"
    }
}

public func == <V: Hashable>(lhs: IdentifiableValue<V>, rhs: IdentifiableValue<V>) -> Bool {
    return lhs.value == rhs.value
}