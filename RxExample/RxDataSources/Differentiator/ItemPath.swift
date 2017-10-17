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

    public init(sectionIndex: Int, itemIndex: Int) {
        self.sectionIndex = sectionIndex
        self.itemIndex = itemIndex
    }
}

extension ItemPath : Equatable {
    
}

public func == (lhs: ItemPath, rhs: ItemPath) -> Bool {
    return lhs.sectionIndex == rhs.sectionIndex && lhs.itemIndex == rhs.itemIndex
}

extension ItemPath: Hashable {

    public var hashValue: Int {
        return sectionIndex.byteSwapped.hashValue ^ itemIndex.hashValue
    }
    
}
