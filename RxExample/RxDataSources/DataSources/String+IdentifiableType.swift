//
//  String+IdentifiableType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/4/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import Foundation

extension String : IdentifiableType {
    public typealias Identity = String

    public var identity: String {
        return self
    }
}
