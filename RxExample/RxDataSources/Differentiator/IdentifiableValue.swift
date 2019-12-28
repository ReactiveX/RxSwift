//
//  IdentifiableValue.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/7/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct IdentifiableValue<Value: Hashable> {
    public let value: Value
}

extension IdentifiableValue
    : IdentifiableType {

    public typealias Identity = Value

    public var identity : Identity {
        value
    }
}

extension IdentifiableValue
    : Equatable
    , CustomStringConvertible
    , CustomDebugStringConvertible {

    public var description: String {
        "\(value)"
    }

    public var debugDescription: String {
        "\(value)"
    }
}

public func == <V>(lhs: IdentifiableValue<V>, rhs: IdentifiableValue<V>) -> Bool {
    return lhs.value == rhs.value
}
