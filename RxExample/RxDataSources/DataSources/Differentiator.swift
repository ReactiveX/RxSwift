//
//  Differentiator.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public enum DifferentiatorError
    : Error
    , CustomDebugStringConvertible {
    case duplicateItem(item: Any)
    case duplicateSection(section: Any)
    case invalidInitializerImplementation(section: Any, expectedItems: Any, expectedIdentifier: Any)
}

extension DifferentiatorError {
    public var debugDescription: String {
        switch self {
        case let .duplicateItem(item):
            return "Duplicate item \(item)"
        case let .duplicateSection(section):
            return "Duplicate section \(section)"
        case let .invalidInitializerImplementation(section, expectedItems, expectedIdentifier):
            return "Wrong initializer implementation for: \(section)\n" +
                "Expected it should return items: \(expectedItems)\n" +
                "Expected it should have id: \(expectedIdentifier)"
        }
    }
}

enum EditEvent : CustomDebugStringConvertible {
    case inserted           // can't be found in old sections
    case insertedAutomatically           // Item inside section being inserted
    case deleted            // Was in old, not in new, in it's place is something "not new" :(, otherwise it's Updated
    case deletedAutomatically            // Item inside section that is being deleted
    case moved              // same item, but was on different index, and needs explicit move
    case movedAutomatically // don't need to specify any changes for those rows
    case untouched
}

extension EditEvent {
    var debugDescription: String {
        get {
            switch self {
            case .inserted:
                return "Inserted"
            case .insertedAutomatically:
                return "InsertedAutomatically"
            case .deleted:
                return "Deleted"
            case .deletedAutomatically:
                return "DeletedAutomatically"
            case .moved:
                return "Moved"
            case .movedAutomatically:
                return "MovedAutomatically"
            case .untouched:
                return "Untouched"
            }
        }
    }
}

struct SectionAssociatedData {
    var event: EditEvent
    var indexAfterDelete: Int?
    var moveIndex: Int?
}

extension SectionAssociatedData : CustomDebugStringConvertible {
    var debugDescription: String {
        get {
            return "\(event), \(indexAfterDelete)"
        }
    }
}

extension SectionAssociatedData {
    static var initial: SectionAssociatedData {
        return SectionAssociatedData(event: .untouched, indexAfterDelete: nil, moveIndex: nil)
    }
}

struct ItemAssociatedData {
    var event: EditEvent
    var indexAfterDelete: Int?
    var moveIndex: ItemPath?
}

extension ItemAssociatedData : CustomDebugStringConvertible {
    var debugDescription: String {
        get {
            return "\(event) \(indexAfterDelete)"
        }
    }
}

extension ItemAssociatedData {
    static var initial : ItemAssociatedData {
        return ItemAssociatedData(event: .untouched, indexAfterDelete: nil, moveIndex: nil)
    }
}

func indexSections<S: AnimatableSectionModelType>(_ sections: [S]) throws -> [S.Identity : Int] {
    var indexedSections: [S.Identity : Int] = [:]
    for (i, section) in sections.enumerated() {
        guard indexedSections[section.identity] == nil else {
            #if DEBUG
                if indexedSections[section.identity] != nil {
                    print("Section \(section) has already been indexed at \(indexedSections[section.identity]!)")
                }
            #endif
            throw DifferentiatorError.duplicateItem(item: section)
        }
        indexedSections[section.identity] = i
    }
    
    return indexedSections
}

func indexSectionItems<S: AnimatableSectionModelType>(_ sections: [S]) throws -> [S.Item.Identity : (Int, Int)] {
    var totalItems = 0
    for i in 0 ..< sections.count {
        totalItems += sections[i].items.count
    }
    
    // let's make sure it's enough
    var indexedItems: [S.Item.Identity : (Int, Int)] = Dictionary(minimumCapacity: totalItems * 3)
    
    for i in 0 ..< sections.count {
        for (j, item) in sections[i].items.enumerated() {
            guard indexedItems[item.identity] == nil else {
                #if DEBUG
                    if indexedItems[item.identity] != nil {
                        print("Item \(item) has already been indexed at \(indexedItems[item.identity]!)" )
                    }
                #endif
                throw DifferentiatorError.duplicateItem(item: item)
            }
            indexedItems[item.identity] = (i, j)
        }
    }
    
    return indexedItems
}


/*

I've uncovered this case during random stress testing of logic.
This is the hardest generic update case that causes two passes, first delete, and then move/insert

[
NumberSection(model: "1", items: [1111]),
NumberSection(model: "2", items: [2222]),
]

[
NumberSection(model: "2", items: [0]),
NumberSection(model: "1", items: []),
]

If update is in the form

* Move section from 2 to 1
* Delete Items at paths 0 - 0, 1 - 0
* Insert Items at paths 0 - 0

or

* Move section from 2 to 1
* Delete Items at paths 0 - 0
* Reload Items at paths 1 - 0

or

* Move section from 2 to 1
* Delete Items at paths 0 - 0
* Reload Items at paths 0 - 0

it crashes table view.

No matter what change is performed, it fails for me.
If anyone knows how to make this work for one Changeset, PR is welcome.

*/

// If you are considering working out your own algorithm, these are tricky
// transition cases that you can use.

// case 1
/*
from = [
    NumberSection(model: "section 4", items: [10, 11, 12]),
    NumberSection(model: "section 9", items: [25, 26, 27]),
]
to = [
    HashableSectionModel(model: "section 9", items: [11, 26, 27]),
    HashableSectionModel(model: "section 4", items: [10, 12])
]
*/

// case 2
/*
from = [
    HashableSectionModel(model: "section 10", items: [26]),
    HashableSectionModel(model: "section 7", items: [5, 29]),
    HashableSectionModel(model: "section 1", items: [14]),
    HashableSectionModel(model: "section 5", items: [16]),
    HashableSectionModel(model: "section 4", items: []),
    HashableSectionModel(model: "section 8", items: [3, 15, 19, 23]),
    HashableSectionModel(model: "section 3", items: [20])
]
to = [
    HashableSectionModel(model: "section 10", items: [26]),
    HashableSectionModel(model: "section 1", items: [14]),
    HashableSectionModel(model: "section 9", items: [3]),
    HashableSectionModel(model: "section 5", items: [16, 8]),
    HashableSectionModel(model: "section 8", items: [15, 19, 23]),
    HashableSectionModel(model: "section 3", items: [20]),
    HashableSectionModel(model: "Section 2", items: [7])
]
*/

// case 3
/*
from = [
    HashableSectionModel(model: "section 4", items: [5]),
    HashableSectionModel(model: "section 6", items: [20, 14]),
    HashableSectionModel(model: "section 9", items: []),
    HashableSectionModel(model: "section 2", items: [2, 26]),
    HashableSectionModel(model: "section 8", items: [23]),
    HashableSectionModel(model: "section 10", items: [8, 18, 13]),
    HashableSectionModel(model: "section 1", items: [28, 25, 6, 11, 10, 29, 24, 7, 19])
]
to = [
    HashableSectionModel(model: "section 4", items: [5]),
    HashableSectionModel(model: "section 6", items: [20, 14]),
    HashableSectionModel(model: "section 9", items: [16]),
    HashableSectionModel(model: "section 7", items: [17, 15, 4]),
    HashableSectionModel(model: "section 2", items: [2, 26, 23]),
    HashableSectionModel(model: "section 8", items: []),
    HashableSectionModel(model: "section 10", items: [8, 18, 13]),
    HashableSectionModel(model: "section 1", items: [28, 25, 6, 11, 10, 29, 24, 7, 19])
]
*/

// Generates differential changes suitable for sectioned view consumption.
// It will not only detect changes between two states, but it will also try to compress those changes into
// almost minimal set of changes.
//
// I know, I know, it's ugly :( Totally agree, but this is the only general way I could find that works 100%, and
// avoids UITableView quirks.
//
// Please take into consideration that I was also convinced about 20 times that I've found a simple general
// solution, but then UITableView falls apart under stress testing :(
//
// Sincerely, if somebody else would present me this 250 lines of code, I would call him a mad man. I would think
// that there has to be a simpler solution. Well, after 3 days, I'm not convinced any more :)
//
// Maybe it can be made somewhat simpler, but don't think it can be made much simpler.
//
// The algorithm could take anywhere from 1 to 3 table view transactions to finish the updates.
//
//  * stage 1 - remove deleted sections and items
//  * stage 2 - move sections into place
//  * stage 3 - fix moved and new items
//
// There maybe exists a better division, but time will tell.
//
public func differencesForSectionedView<S: AnimatableSectionModelType>(
        _ initialSections: [S],
        finalSections: [S]
    )
    throws -> [Changeset<S>] {
    typealias I = S.Item

    var result: [Changeset<S>] = []

    var sectionCommands = try CommandGenerator<S>.generatorForInitialSections(initialSections, finalSections: finalSections)

    result.append(contentsOf: try sectionCommands.generateDeleteSections())
    result.append(contentsOf: try sectionCommands.generateInsertAndMoveSections())
    result.append(contentsOf: try sectionCommands.generateNewAndMovedItems())

    return result
}

private extension AnimatableSectionModelType {
    init(safeOriginal: Self, safeItems: [Item]) throws {
        self.init(original: safeOriginal, items: safeItems)

        if self.items != safeItems || self.identity != safeOriginal.identity {
            throw DifferentiatorError.invalidInitializerImplementation(section: self, expectedItems: safeItems, expectedIdentifier: safeOriginal.identity)
        }
    }
}

struct CommandGenerator<S: AnimatableSectionModelType> {
    let initialSections: [S]
    let finalSections: [S]

    let initialSectionData: [SectionAssociatedData]
    let finalSectionData: [SectionAssociatedData]

    let initialItemData: [[ItemAssociatedData]]
    let finalItemData: [[ItemAssociatedData]]

    static func generatorForInitialSections(
        _ initialSections: [S],
        finalSections: [S]
    ) throws -> CommandGenerator<S> {

        let (initialSectionData, finalSectionData) = try calculateSectionMovementsForInitialSections(initialSections, finalSections: finalSections)
        let (initialItemData, finalItemData) = try calculateItemMovementsForInitialSections(initialSections,
            finalSections: finalSections,
            initialSectionData: initialSectionData,
            finalSectionData: finalSectionData
        )
        
        return CommandGenerator<S>(
            initialSections: initialSections,
            finalSections: finalSections,

            initialSectionData: initialSectionData,
            finalSectionData: finalSectionData,

            initialItemData: initialItemData,
            finalItemData: finalItemData
        )
    }

    static func calculateItemMovementsForInitialSections(_ initialSections: [S], finalSections: [S],
        initialSectionData: [SectionAssociatedData], finalSectionData: [SectionAssociatedData]) throws -> ([[ItemAssociatedData]], [[ItemAssociatedData]]) {
        var initialItemData = initialSections.map { s in
            return [ItemAssociatedData](repeating: ItemAssociatedData.initial, count: s.items.count)
        }

        var finalItemData = finalSections.map { s in
            return [ItemAssociatedData](repeating: ItemAssociatedData.initial, count: s.items.count)
        }

        let initialItemIndexes = try indexSectionItems(initialSections)

        for i in 0 ..< finalSections.count {
            for (j, item) in finalSections[i].items.enumerated() {
                guard let initialItemIndex = initialItemIndexes[item.identity] else {
                    continue
                }
                if initialItemData[initialItemIndex.0][initialItemIndex.1].moveIndex != nil {
                    throw DifferentiatorError.duplicateItem(item: item)
                }

                initialItemData[initialItemIndex.0][initialItemIndex.1].moveIndex = ItemPath(sectionIndex: i, itemIndex: j)
                finalItemData[i][j].moveIndex = ItemPath(sectionIndex: initialItemIndex.0, itemIndex: initialItemIndex.1)
            }
        }

        let findNextUntouchedOldIndex = { (initialSectionIndex: Int, initialSearchIndex: Int?) -> Int? in
            guard var i2 = initialSearchIndex else {
                return nil
            }

            while i2 < initialSections[initialSectionIndex].items.count {
                if initialItemData[initialSectionIndex][i2].event == .untouched {
                    return i2
                }

                i2 = i2 + 1
            }

            return nil
        }

        // first mark deleted items
        for i in 0 ..< initialSections.count {
            guard let _ = initialSectionData[i].moveIndex else {
                continue
            }

            var indexAfterDelete = 0
            for j in 0 ..< initialSections[i].items.count {

                guard let finalIndexPath = initialItemData[i][j].moveIndex else {
                    initialItemData[i][j].event = .deleted
                    continue
                }

                // from this point below, section has to be move type because it's initial and not deleted

                // because there is no move to inserted section
                if finalSectionData[finalIndexPath.sectionIndex].event == .inserted {
                    initialItemData[i][j].event = .deleted
                    continue
                }

                initialItemData[i][j].indexAfterDelete = indexAfterDelete
                indexAfterDelete += 1
            }
        }

        // mark moved or moved automatically
        for i in 0 ..< finalSections.count {
            guard let originalSectionIndex = finalSectionData[i].moveIndex else {
                continue
            }

            var untouchedIndex: Int? = 0
            for j in 0 ..< finalSections[i].items.count {
                untouchedIndex = findNextUntouchedOldIndex(originalSectionIndex, untouchedIndex)

                guard let originalIndex = finalItemData[i][j].moveIndex else {
                    finalItemData[i][j].event = .inserted
                    continue
                }

                // In case trying to move from deleted section, abort, otherwise it will crash table view
                if initialSectionData[originalIndex.sectionIndex].event == .deleted {
                    finalItemData[i][j].event = .inserted
                    continue
                }
                // original section can't be inserted
                else if initialSectionData[originalIndex.sectionIndex].event == .inserted {
                    try rxPrecondition(false, "New section in initial sections, that is wrong")
                }

                let initialSectionEvent = initialSectionData[originalIndex.sectionIndex].event
                try rxPrecondition(initialSectionEvent == .moved || initialSectionEvent == .movedAutomatically, "Section not moved")

                let eventType = originalIndex == ItemPath(sectionIndex: originalSectionIndex, itemIndex: untouchedIndex ?? -1)
                    ? EditEvent.movedAutomatically : EditEvent.moved

                initialItemData[originalIndex.sectionIndex][originalIndex.itemIndex].event = eventType
                finalItemData[i][j].event = eventType

            }
        }

        return (initialItemData, finalItemData)
    }

    static func calculateSectionMovementsForInitialSections(_ initialSections: [S], finalSections: [S]) throws -> ([SectionAssociatedData], [SectionAssociatedData]) {

        let initialSectionIndexes = try indexSections(initialSections)

        var initialSectionData = [SectionAssociatedData](repeating: SectionAssociatedData.initial, count: initialSections.count)
        var finalSectionData = [SectionAssociatedData](repeating: SectionAssociatedData.initial, count: finalSections.count)

        for (i, section) in finalSections.enumerated() {
            guard let initialSectionIndex = initialSectionIndexes[section.identity] else {
                continue
            }

            if initialSectionData[initialSectionIndex].moveIndex != nil {
                throw DifferentiatorError.duplicateSection(section: section)
            }

            initialSectionData[initialSectionIndex].moveIndex = i
            finalSectionData[i].moveIndex = initialSectionIndex
        }

        var sectionIndexAfterDelete = 0

        // deleted sections
        for i in 0 ..< initialSectionData.count {
            if initialSectionData[i].moveIndex == nil {
                initialSectionData[i].event = .deleted
                continue
            }

            initialSectionData[i].indexAfterDelete = sectionIndexAfterDelete
            sectionIndexAfterDelete += 1
        }

        // moved sections

        var untouchedOldIndex: Int? = 0
        let findNextUntouchedOldIndex = { (initialSearchIndex: Int?) -> Int? in
            guard var i = initialSearchIndex else {
                return nil
            }

            while i < initialSections.count {
                if initialSectionData[i].event == .untouched {
                    return i
                }

                i = i + 1
            }

            return nil
        }

        // inserted and moved sections {
        // this should fix all sections and move them into correct places
        // 2nd stage
        for i in 0 ..< finalSections.count {
            untouchedOldIndex = findNextUntouchedOldIndex(untouchedOldIndex)

            // oh, it did exist
            if let oldSectionIndex = finalSectionData[i].moveIndex {
                let moveType = oldSectionIndex != untouchedOldIndex ? EditEvent.moved : EditEvent.movedAutomatically

                finalSectionData[i].event = moveType
                initialSectionData[oldSectionIndex].event = moveType
            }
            else {
                finalSectionData[i].event = .inserted
            }
        }

        // inserted sections
        for (i, section) in finalSectionData.enumerated() {
            if section.moveIndex == nil {
                _ = finalSectionData[i].event == .inserted
            }
        }
        
        return (initialSectionData, finalSectionData)
    }

    mutating func generateDeleteSections() throws -> [Changeset<S>] {
        var deletedSections = [Int]()
        var deletedItems = [ItemPath]()
        var updatedItems = [ItemPath]()

        var afterDeleteState = [S]()

        // mark deleted items {
        // 1rst stage again (I know, I know ...)
        for (i, initialSection) in initialSections.enumerated() {
            let event = initialSectionData[i].event

            // Deleted section will take care of deleting child items.
            // In case of moving an item from deleted section, tableview will
            // crash anyway, so this is not limiting anything.
            if event == .deleted {
                deletedSections.append(i)
                continue
            }

            var afterDeleteItems: [S.Item] = []
            for j in 0 ..< initialSection.items.count {
                let event = initialItemData[i][j].event
                switch event {
                case .deleted:
                    deletedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                case .moved, .movedAutomatically:
                    let finalItemIndex = try initialItemData[i][j].moveIndex.unwrap()
                    let finalItem = finalSections[finalItemIndex]
                    if finalItem != initialSections[i].items[j] {
                        updatedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                    }
                    afterDeleteItems.append(finalItem)
                default:
                    try rxPrecondition(false, "Unhandled case")
                }
            }

            afterDeleteState.append(try S(safeOriginal: initialSection, safeItems: afterDeleteItems))
        }
        // }

        if deletedItems.count == 0 && deletedSections.count == 0 && updatedItems.count == 0 {
            return []
        }

        return [Changeset(
            finalSections: afterDeleteState,
            deletedSections: deletedSections,
            deletedItems: deletedItems,
            updatedItems: updatedItems
        )]
    }

    func generateInsertAndMoveSections() throws -> [Changeset<S>] {

        var movedSections = [(from: Int, to: Int)]()
        var insertedSections = [Int]()

        for i in 0 ..< initialSections.count {
            switch initialSectionData[i].event {
            case .deleted:
                break
            case .moved:
                movedSections.append((from: try initialSectionData[i].indexAfterDelete.unwrap(), to: try initialSectionData[i].moveIndex.unwrap()))
            case .movedAutomatically:
                break
            default:
                try rxPrecondition(false, "Unhandled case in initial sections")
            }
        }

        for i in 0 ..< finalSections.count {
            switch finalSectionData[i].event {
            case .inserted:
                insertedSections.append(i)
            default:
                break
            }
        }

        if insertedSections.count ==  0 && movedSections.count == 0 {
            return []
        }

        // sections should be in place, but items should be original without deleted ones
        let sectionsAfterChange: [S] = try self.finalSections.enumerated().map { i, s -> S in
            let event = self.finalSectionData[i].event
            
            if event == .inserted {
                // it's already set up
                return s
            }
            else if event == .moved || event == .movedAutomatically {
                let originalSectionIndex = try finalSectionData[i].moveIndex.unwrap()
                let originalSection = initialSections[originalSectionIndex]
                
                var items: [S.Item] = []
                for (j, _) in originalSection.items.enumerated() {
                    let initialData = self.initialItemData[originalSectionIndex][j]

                    guard initialData.event != .deleted else {
                        continue
                    }

                    guard let finalIndex = initialData.moveIndex else {
                        try rxPrecondition(false, "Item was moved, but no final location.")
                        continue
                    }

                    items.append(self.finalSections[finalIndex.sectionIndex].items[finalIndex.itemIndex])
                }
                
                let modifiedSection = try S(safeOriginal: s, safeItems: items)

                return modifiedSection
            }
            else {
                try rxPrecondition(false, "This is weird, this shouldn't happen")
                return s
            }
        }

        return [Changeset(
            finalSections: sectionsAfterChange,
            insertedSections:  insertedSections,
            movedSections: movedSections
        )]
    }

    mutating func generateNewAndMovedItems() throws -> [Changeset<S>] {
        var insertedItems = [ItemPath]()
        var movedItems = [(from: ItemPath, to: ItemPath)]()

        // mark new and moved items {
        // 3rd stage
        for i in 0 ..< finalSections.count {
            let finalSection = finalSections[i]
            
            let sectionEvent = finalSectionData[i].event
            // new and deleted sections cause reload automatically
            if sectionEvent != .moved && sectionEvent != .movedAutomatically {
                continue
            }
            
            for j in 0 ..< finalSection.items.count {
                let currentItemEvent = finalItemData[i][j].event
                
                try rxPrecondition(currentItemEvent != .untouched, "Current event is not untouched")

                let event = finalItemData[i][j].event

                switch event {
                case .inserted:
                    insertedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                case .moved:
                    let originalIndex = try finalItemData[i][j].moveIndex.unwrap()
                    let finalSectionIndex = try initialSectionData[originalIndex.sectionIndex].moveIndex.unwrap()
                    let moveFromItemWithIndex = try initialItemData[originalIndex.sectionIndex][originalIndex.itemIndex].indexAfterDelete.unwrap()

                    let moveCommand = (
                        from: ItemPath(sectionIndex: finalSectionIndex, itemIndex: moveFromItemWithIndex),
                        to: ItemPath(sectionIndex: i, itemIndex: j)
                    )
                    movedItems.append(moveCommand)
                default:
                    break
                }
            }
        }
        // }

        if insertedItems.count == 0 && movedItems.count == 0 {
            return []
        }
        return [Changeset(
            finalSections: finalSections,
            insertedItems: insertedItems,
            movedItems: movedItems
        )]
    }
}
