//
//  Changeset.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/30/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreData
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

struct ItemPath : CustomDebugStringConvertible {
    let sectionIndex: Int
    let itemIndex: Int

    var debugDescription : String {
        get {
            return "(\(sectionIndex), \(itemIndex))"
        }
    }
}

public struct Changeset<S: SectionModelType> : CustomDebugStringConvertible {
    typealias I = S.Item

    var reloadData: Bool = false

    var finalSections: [S] = []

    var insertedSections: [Int] = []
    var deletedSections: [Int] = []
    var movedSections: [(from: Int, to: Int)] = []
    var updatedSections: [Int] = []

    var insertedItems: [ItemPath] = []
    var deletedItems: [ItemPath] = []
    var movedItems: [(from: ItemPath, to: ItemPath)] = []
    var updatedItems: [ItemPath] = []

    public static func initialValue(sections: [S]) -> Changeset<S> {
        var initialValue = Changeset<S>()
        initialValue.insertedSections = Array(0 ..< sections.count)
        initialValue.finalSections = sections
        initialValue.reloadData = true
        
        return initialValue
    }

    public var debugDescription : String {
        get {
            let serializedSections = "[\n" + finalSections.map { "\($0)" }.joinWithSeparator(",\n") + "\n]\n"
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
}
