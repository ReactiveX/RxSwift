//
//  IntegerType+IdentifiableType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if swift(>=4.0)
extension FixedWidthInteger {
    typealias identity = Self

    public var identity: Self {
        return self
    }
}
#else
extension Integer {
    typealias identity = Self

    public var identity: Self {
        return self
    }
}
#endif

extension Int : IdentifiableType {

}

extension Int8 : IdentifiableType {

}

extension Int16 : IdentifiableType {

}

extension Int32 : IdentifiableType {

}

extension Int64 : IdentifiableType {

}


extension UInt : IdentifiableType {

}

extension UInt8 : IdentifiableType {

}

extension UInt16 : IdentifiableType {

}

extension UInt32 : IdentifiableType {

}

extension UInt64 : IdentifiableType {
    
}

