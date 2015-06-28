//
//  SectionModelType.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol SectionModelType {
    typealias Item
    
    var items: [Item] { get }
    
    init(original: Self, items: [Item])
}