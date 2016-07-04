//
//  FloatingPointType+IdentifiableType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/4/16.
//  Copyright © 2016 kzaher. All rights reserved.
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

extension Float80 : IdentifiableType {
    typealias identity = Float80

    public var identity: Float80 {
        return self
    }
}
