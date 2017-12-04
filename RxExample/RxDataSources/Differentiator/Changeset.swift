//
//  Changeset.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 5/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct Changeset<S: SectionModelType> {
    public typealias I = S.Item

    public let reloadData: Bool

    public let originalSections: [S]
    public let finalSections: [S]

    public let insertedSections: [Int]
    public let deletedSections: [Int]
    public let movedSections: [(from: Int, to: Int)]
    public let updatedSections: [Int]

    public let insertedItems: [ItemPath]
    public let deletedItems: [ItemPath]
    public let movedItems: [(from: ItemPath, to: ItemPath)]
    public let updatedItems: [ItemPath]

    init(reloadData: Bool = false,
        originalSections: [S] = [],
        finalSections: [S] = [],
        insertedSections: [Int] = [],
        deletedSections: [Int] = [],
        movedSections: [(from: Int, to: Int)] = [],
        updatedSections: [Int] = [],

        insertedItems: [ItemPath] = [],
        deletedItems: [ItemPath] = [],
        movedItems: [(from: ItemPath, to: ItemPath)] = [],
        updatedItems: [ItemPath] = []
    ) {
        self.reloadData = reloadData

        self.originalSections = originalSections
        self.finalSections = finalSections

        self.insertedSections = insertedSections
        self.deletedSections = deletedSections
        self.movedSections = movedSections
        self.updatedSections = updatedSections

        self.insertedItems = insertedItems
        self.deletedItems = deletedItems
        self.movedItems = movedItems
        self.updatedItems = updatedItems
    }

    public static func initialValue(_ sections: [S]) -> Changeset<S> {
        return Changeset<S>(
            reloadData: true,
            finalSections: sections,
            insertedSections: Array(0 ..< sections.count) as [Int]
        )
    }
}

extension ItemPath
    : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "(\(sectionIndex), \(itemIndex))"
    }
}

extension Changeset
    : CustomDebugStringConvertible {

    public var debugDescription : String {
        let serializedSections = "[\n" + finalSections.map { "\($0)" }.joined(separator: ",\n") + "\n]\n"
        return " >> Final sections"
        + "   \n\(serializedSections)"
        + (insertedSections.count > 0 || deletedSections.count > 0 || movedSections.count > 0 || updatedSections.count > 0 ? "\nSections:" : "")
        + (insertedSections.count > 0 ? "\ninsertedSections:\n\t\(insertedSections)" : "")
        + (deletedSections.count > 0 ?  "\ndeletedSections:\n\t\(deletedSections)" : "")
        + (movedSections.count > 0 ? "\nmovedSections:\n\t\(movedSections)" : "")
        + (updatedSections.count > 0 ? "\nupdatesSections:\n\t\(updatedSections)" : "")
            + (insertedItems.count > 0 || deletedItems.count > 0 || movedItems.count > 0 || updatedItems.count > 0 ? "\nItems:" : "")
        + (insertedItems.count > 0 ? "\ninsertedItems:\n\t\(insertedItems)" : "")
        + (deletedItems.count > 0 ? "\ndeletedItems:\n\t\(deletedItems)" : "")
        + (movedItems.count > 0 ? "\nmovedItems:\n\t\(movedItems)" : "")
        + (updatedItems.count > 0 ? "\nupdatedItems:\n\t\(updatedItems)" : "")
    }
}
