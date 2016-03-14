//
//  IdentifiableType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/6/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol IdentifiableType {
    typealias Identity: Hashable

    var identity : Identity { get }
}