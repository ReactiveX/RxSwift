//
//  UI+SectionedViewType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

extension UITableView: SectionedViewType {
    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        insertRows(at: paths, with: animationStyle)
    }

    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        deleteRows(at: paths, with: animationStyle)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        moveRow(at: from, to: to)
    }

    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        reloadRows(at: paths, with: animationStyle)
    }

    public func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        insertSections(indexSet(sections), with: animationStyle)
    }

    public func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        deleteSections(indexSet(sections), with: animationStyle)
    }

    public func moveSection(_ from: Int, to: Int) {
        moveSection(from, toSection: to)
    }

    public func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        reloadSections(indexSet(sections), with: animationStyle)
    }

    public func performBatchUpdates(_ changes: Changeset<some Any>, animationConfiguration: AnimationConfiguration) {
        beginUpdates()
        _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        endUpdates()
    }
}

extension UICollectionView: SectionedViewType {
    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle _: UITableView.RowAnimation) {
        insertItems(at: paths)
    }

    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle _: UITableView.RowAnimation) {
        deleteItems(at: paths)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        moveItem(at: from, to: to)
    }

    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle _: UITableView.RowAnimation) {
        reloadItems(at: paths)
    }

    public func insertSections(_ sections: [Int], animationStyle _: UITableView.RowAnimation) {
        insertSections(indexSet(sections))
    }

    public func deleteSections(_ sections: [Int], animationStyle _: UITableView.RowAnimation) {
        deleteSections(indexSet(sections))
    }

    public func moveSection(_ from: Int, to: Int) {
        moveSection(from, toSection: to)
    }

    public func reloadSections(_ sections: [Int], animationStyle _: UITableView.RowAnimation) {
        reloadSections(indexSet(sections))
    }

    public func performBatchUpdates(_ changes: Changeset<some Any>, animationConfiguration: AnimationConfiguration) {
        performBatchUpdates({ () in
            _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        }, completion: { (_: Bool) in
        })
    }
}

public protocol SectionedViewType {
    func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath)
    func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)

    func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
    func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
    func moveSection(_ from: Int, to: Int)
    func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)

    func performBatchUpdates(_ changes: Changeset<some Any>, animationConfiguration: AnimationConfiguration)
}

func _performBatchUpdates<S>(_ view: some SectionedViewType, changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
    typealias I = S.Item

    view.deleteSections(changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
    // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
    // otherwise all cells will be reloaded for nothing.
    // view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
    view.insertSections(changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
    for (from, to) in changes.movedSections {
        view.moveSection(from, to: to)
    }

    view.deleteItemsAtIndexPaths(
        changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.deleteAnimation
    )
    view.insertItemsAtIndexPaths(
        changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.insertAnimation
    )
    view.reloadItemsAtIndexPaths(
        changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.reloadAnimation
    )

    for (from, to) in changes.movedItems {
        view.moveItemAtIndexPath(
            IndexPath(item: from.itemIndex, section: from.sectionIndex),
            to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
        )
    }
}
#endif
