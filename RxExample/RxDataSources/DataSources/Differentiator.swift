//
//  Differentiator.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public enum DifferentiatorError
    : ErrorType
    , CustomDebugStringConvertible {
    case DuplicateItem(item: Any)
    case DuplicateSection(section: Any)
}

extension DifferentiatorError {
    public var debugDescription: String {
        switch self {
        case let .DuplicateItem(item):
            return "Duplicate item \(item)"
        case let .DuplicateSection(section):
            return "Duplicate section \(section)"
        }
    }
}

enum EditEvent : CustomDebugStringConvertible {
    case Inserted           // can't be found in old sections
    case InsertedAutomatically           // Item inside section being inserted
    case Deleted            // Was in old, not in new, in it's place is something "not new" :(, otherwise it's Updated
    case DeletedAutomatically            // Item inside section that is being deleted
    case Moved              // same item, but was on different index, and needs explicit move
    case MovedAutomatically // don't need to specify any changes for those rows
    case Untouched
}

extension EditEvent {
    var debugDescription: String {
        get {
            switch self {
            case .Inserted:
                return "Inserted"
            case .InsertedAutomatically:
                return "InsertedAutomatically"
            case .Deleted:
                return "Deleted"
            case .DeletedAutomatically:
                return "DeletedAutomatically"
            case .Moved:
                return "Moved"
            case .MovedAutomatically:
                return "MovedAutomatically"
            case .Untouched:
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
        return SectionAssociatedData(event: .Untouched, indexAfterDelete: nil, moveIndex: nil)
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
        return ItemAssociatedData(event: .Untouched, indexAfterDelete: nil, moveIndex: nil)
    }
}

func indexSections<S: AnimatableSectionModelType>(sections: [S]) throws -> [S.Identity : Int] {
    var indexedSections: [S.Identity : Int] = [:]
    for (i, section) in sections.enumerate() {
        guard indexedSections[section.identity] == nil else {
            #if DEBUG
            precondition(indexedSections[section.identity] == nil, "Section \(section) has already been indexed at \(indexedSections[section.identity]!)")
            #endif
            throw DifferentiatorError.DuplicateItem(item: section)
        }
        indexedSections[section.identity] = i
    }
    
    return indexedSections
}

func indexSectionItems<S: AnimatableSectionModelType>(sections: [S]) throws -> [S.Item.Identity : (Int, Int)] {
    var totalItems = 0
    for i in 0 ..< sections.count {
        totalItems += sections[i].items.count
    }
    
    // let's make sure it's enough
    var indexedItems: [S.Item.Identity : (Int, Int)] = Dictionary(minimumCapacity: totalItems * 3)
    
    for i in 0 ..< sections.count {
        for (j, item) in sections[i].items.enumerate() {
            guard indexedItems[item.identity] == nil else {
                #if DEBUG
                precondition(indexedItems[item.identity] == nil, "Item \(item) has already been indexed at \(indexedItems[item.identity]!)" )
                #endif
                throw DifferentiatorError.DuplicateItem(item: item)
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
        initialSections: [S],
        finalSections: [S]
    )
    throws -> [Changeset<S>] {
    typealias I = S.Item

    var result: [Changeset<S>] = []

    var sectionCommands = try CommandGenerator<S>.generatorForInitialSections(initialSections, finalSections: finalSections)

    result.appendContentsOf(try sectionCommands.generateDeleteSections())
    result.appendContentsOf(try sectionCommands.generateInsertAndMoveSections())
    result.appendContentsOf(try sectionCommands.generateNewAndMovedItems())

    return result
}

struct CommandGenerator<S: AnimatableSectionModelType> {
    let initialSections: [S]
    let finalSections: [S]

    let initialSectionData: [SectionAssociatedData]
    let finalSectionData: [SectionAssociatedData]

    let initialItemData: [[ItemAssociatedData]]
    let finalItemData: [[ItemAssociatedData]]

    static func generatorForInitialSections(
        initialSections: [S],
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

    static func calculateItemMovementsForInitialSections(initialSections: [S], finalSections: [S],
        initialSectionData: [SectionAssociatedData], finalSectionData: [SectionAssociatedData]) throws -> ([[ItemAssociatedData]], [[ItemAssociatedData]]) {
        var initialItemData = initialSections.map { s in
            return [ItemAssociatedData](count: s.items.count, repeatedValue: ItemAssociatedData.initial)
        }

        var finalItemData = finalSections.map { s in
            return [ItemAssociatedData](count: s.items.count, repeatedValue: ItemAssociatedData.initial)
        }

        let initialItemIndexes = try indexSectionItems(initialSections)

        for i in 0 ..< finalSections.count {
            for (j, item) in finalSections[i].items.enumerate() {
                guard let initialItemIndex = initialItemIndexes[item.identity] else {
                    continue
                }
                if initialItemData[initialItemIndex.0][initialItemIndex.1].moveIndex != nil {
                    throw DifferentiatorError.DuplicateItem(item: item)
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
                if initialItemData[initialSectionIndex][i2].event == .Untouched {
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
                    initialItemData[i][j].event = .Deleted
                    continue
                }

                // from this point below, section has to be move type because it's initial and not deleted

                // because there is no move to inserted section
                if finalSectionData[finalIndexPath.sectionIndex].event == .Inserted {
                    initialItemData[i][j].event = .Deleted
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
                    finalItemData[i][j].event = .Inserted
                    continue
                }

                // In case trying to move from deleted section, abort, otherwise it will crash table view
                if initialSectionData[originalIndex.sectionIndex].event == .Deleted {
                    finalItemData[i][j].event = .Inserted
                    continue
                }
                // original section can't be inserted
                else if initialSectionData[originalIndex.sectionIndex].event == .Inserted {
                    try rxPrecondition(false, "New section in initial sections, that is wrong")
                }

                let initialSectionEvent = initialSectionData[originalIndex.sectionIndex].event
                try rxPrecondition(initialSectionEvent == .Moved || initialSectionEvent == .MovedAutomatically, "Section not moved")

                let eventType = originalIndex == ItemPath(sectionIndex: originalSectionIndex, itemIndex: untouchedIndex ?? -1)
                    ? EditEvent.MovedAutomatically : EditEvent.Moved

                initialItemData[originalIndex.sectionIndex][originalIndex.itemIndex].event = eventType
                finalItemData[i][j].event = eventType

            }
        }

        return (initialItemData, finalItemData)
    }

    static func calculateSectionMovementsForInitialSections(initialSections: [S], finalSections: [S]) throws -> ([SectionAssociatedData], [SectionAssociatedData]) {

        let initialSectionIndexes = try indexSections(initialSections)

        var initialSectionData = [SectionAssociatedData](count: initialSections.count, repeatedValue: SectionAssociatedData.initial)
        var finalSectionData = [SectionAssociatedData](count: finalSections.count, repeatedValue: SectionAssociatedData.initial)

        for (i, section) in finalSections.enumerate() {
            guard let initialSectionIndex = initialSectionIndexes[section.identity] else {
                continue
            }

            if initialSectionData[initialSectionIndex].moveIndex != nil {
                throw DifferentiatorError.DuplicateSection(section: section)
            }

            initialSectionData[initialSectionIndex].moveIndex = i
            finalSectionData[i].moveIndex = initialSectionIndex
        }

        var sectionIndexAfterDelete = 0

        // deleted sections
        for i in 0 ..< initialSectionData.count {
            if initialSectionData[i].moveIndex == nil {
                initialSectionData[i].event = .Deleted
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
                if initialSectionData[i].event == .Untouched {
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
                let moveType = oldSectionIndex != untouchedOldIndex ? EditEvent.Moved : EditEvent.MovedAutomatically

                finalSectionData[i].event = moveType
                initialSectionData[oldSectionIndex].event = moveType
            }
            else {
                finalSectionData[i].event = .Inserted
            }
        }

        // inserted sections
        for (i, section) in finalSectionData.enumerate() {
            if section.moveIndex == nil {
                finalSectionData[i].event == .Inserted
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
        for (i, initialSection) in initialSections.enumerate() {
            let event = initialSectionData[i].event

            // Deleted section will take care of deleting child items.
            // In case of moving an item from deleted section, tableview will
            // crash anyway, so this is not limiting anything.
            if event == .Deleted {
                deletedSections.append(i)
                continue
            }

            var afterDeleteItems: [S.Item] = []
            for j in 0 ..< initialSection.items.count {
                let event = initialItemData[i][j].event
                switch event {
                case .Deleted:
                    deletedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                case .Moved, .MovedAutomatically:
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

            afterDeleteState.append(S(original: initialSection, items: afterDeleteItems))
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
            case .Deleted:
                break
            case .Moved:
                movedSections.append((from: try initialSectionData[i].indexAfterDelete.unwrap(), to: try initialSectionData[i].moveIndex.unwrap()))
            case .MovedAutomatically:
                break
            default:
                try rxPrecondition(false, "Unhandled case in initial sections")
            }
        }

        for i in 0 ..< finalSections.count {
            switch finalSectionData[i].event {
            case .Inserted:
                insertedSections.append(i)
            default:
                break
            }
        }

        if insertedSections.count ==  0 && movedSections.count == 0 {
            return []
        }

        // sections should be in place, but items should be original without deleted ones
        let sectionsAfterChange: [S] = try self.finalSections.enumerate().map { i, s -> S in
            let event = self.finalSectionData[i].event
            
            if event == .Inserted {
                // it's already set up
                return s
            }
            else if event == .Moved || event == .MovedAutomatically {
                let originalSectionIndex = try finalSectionData[i].moveIndex.unwrap()
                let originalSection = initialSections[originalSectionIndex]
                
                var items: [S.Item] = []
                for (j, _) in originalSection.items.enumerate() {
                    let initialData = self.initialItemData[originalSectionIndex][j]

                    guard initialData.event != .Deleted else {
                        continue
                    }

                    guard let finalIndex = initialData.moveIndex else {
                        try rxPrecondition(false, "Item was moved, but no final location.")
                        continue
                    }

                    items.append(self.finalSections[finalIndex.sectionIndex].items[finalIndex.itemIndex])
                }
                
                return S(original: s, items: items)
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
            if sectionEvent != .Moved && sectionEvent != .MovedAutomatically {
                continue
            }
            
            for j in 0 ..< finalSection.items.count {
                let currentItemEvent = finalItemData[i][j].event
                
                try rxPrecondition(currentItemEvent != .Untouched, "Current event is not untouched")

                let event = finalItemData[i][j].event

                switch event {
                case .Inserted:
                    insertedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                case .Moved:
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