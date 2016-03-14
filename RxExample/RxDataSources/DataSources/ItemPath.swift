//
//  ItemPath.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/9/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct ItemPath {
    public let sectionIndex: Int
    public let itemIndex: Int
}

extension ItemPath : Equatable {
    
}

public func == (lhs: ItemPath, rhs: ItemPath) -> Bool {
    return lhs.sectionIndex == rhs.sectionIndex && lhs.itemIndex == rhs.itemIndex
}