//
//  Array+Extensions.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 4/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

import Foundation

extension Array where Element: SectionModelType {
    mutating func moveFromSourceIndexPath(sourceIndexPath: NSIndexPath, destinationIndexPath: NSIndexPath) {
        let sourceSection = self[sourceIndexPath.section]
        var sourceItems = sourceSection.items

        let sourceItem = sourceItems.removeAtIndex(sourceIndexPath.item)

        let sourceSectionNew = Element(original: sourceSection, items: sourceItems)
        self[sourceIndexPath.section] = sourceSectionNew

        let destinationSection = self[destinationIndexPath.section]
        var destinationItems = destinationSection.items
        destinationItems.insert(sourceItem, atIndex: destinationIndexPath.item)

        self[destinationIndexPath.section] = Element(original: destinationSection, items: destinationItems)
    }
}