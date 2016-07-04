//
//  FloatingPointType+IdentifiableType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension FloatingPointType {
    typealias identity = Self

    public var identity: Self {
        return self
    }
}

extension Float : IdentifiableType {

}

extension Double : IdentifiableType {

}

#if swift(>=3.0)
extension Float80 : IdentifiableType {
    typealias identity = Float80

    public var identity: Float80 {
        return self
    }
}
#endif
