//
//  UI+SectionedViewType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

func indexSet(values: [Int]) -> NSIndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.addIndex(i)
    }
    return indexSet
}

extension UITableView : SectionedViewType {
  
    public func insertItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertRowsAtIndexPaths(paths, withRowAnimation: animationStyle)
    }
    
    public func deleteItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteRowsAtIndexPaths(paths, withRowAnimation: animationStyle)
    }
    
    public func moveItemAtIndexPath(from: NSIndexPath, to: NSIndexPath) {
        self.moveRowAtIndexPath(from, toIndexPath: to)
    }
    
    public func reloadItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadRowsAtIndexPaths(paths, withRowAnimation: animationStyle)
    }
    
    public func insertSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections), withRowAnimation: animationStyle)
    }
    
    public func deleteSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections), withRowAnimation: animationStyle)
    }
    
    public func moveSection(from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    public func reloadSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections), withRowAnimation: animationStyle)
    }

  public func performBatchUpdates<S: SectionModelType>(changes: Changeset<S>, animationConfiguration: AnimationConfiguration?=nil) {
        self.beginUpdates()
      _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        self.endUpdates()
    }
}

extension UICollectionView : SectionedViewType {
    public func insertItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertItemsAtIndexPaths(paths)
    }
    
    public func deleteItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteItemsAtIndexPaths(paths)
    }

    public func moveItemAtIndexPath(from: NSIndexPath, to: NSIndexPath) {
        self.moveItemAtIndexPath(from, toIndexPath: to)
    }
    
    public func reloadItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadItemsAtIndexPaths(paths)
    }
    
    public func insertSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections))
    }
    
    public func deleteSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections))
    }
    
    public func moveSection(from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    public func reloadSections(sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections))
    }
    
  public func performBatchUpdates<S: SectionModelType>(changes: Changeset<S>, animationConfiguration:AnimationConfiguration?=nil) {
        self.performBatchUpdates({ () -> Void in
            _performBatchUpdates(self, changes: changes)
        }, completion: { (completed: Bool) -> Void in
        })
    }
}

public protocol SectionedViewType {
    func insertItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation)
    func deleteItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation)
    func moveItemAtIndexPath(from: NSIndexPath, to: NSIndexPath)
    func reloadItemsAtIndexPaths(paths: [NSIndexPath], animationStyle: UITableViewRowAnimation)
    
    func insertSections(sections: [Int], animationStyle: UITableViewRowAnimation)
    func deleteSections(sections: [Int], animationStyle: UITableViewRowAnimation)
    func moveSection(from: Int, to: Int)
    func reloadSections(sections: [Int], animationStyle: UITableViewRowAnimation)

    func performBatchUpdates<S>(changes: Changeset<S>, animationConfiguration: AnimationConfiguration?)
}

func _performBatchUpdates<V: SectionedViewType, S: SectionModelType>(view: V, changes: Changeset<S>, animationConfiguration :AnimationConfiguration?=nil) {
    typealias I = S.Item
  
    let animationConfiguration = animationConfiguration ?? AnimationConfiguration()
    view.deleteSections(changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
    // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
    // otherwise all cells will be reloaded for nothing.
    //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
    view.insertSections(changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
    for (from, to) in changes.movedSections {
        view.moveSection(from, to: to)
    }
    
    view.deleteItemsAtIndexPaths(
        changes.deletedItems.map { NSIndexPath(forItem: $0.itemIndex, inSection: $0.sectionIndex) },
        animationStyle: animationConfiguration.deleteAnimation
    )
    view.insertItemsAtIndexPaths(
        changes.insertedItems.map { NSIndexPath(forItem: $0.itemIndex, inSection: $0.sectionIndex) },
        animationStyle: animationConfiguration.insertAnimation
    )
    view.reloadItemsAtIndexPaths(
        changes.updatedItems.map { NSIndexPath(forItem: $0.itemIndex, inSection: $0.sectionIndex) },
        animationStyle: animationConfiguration.reloadAnimation
    )
    
    for (from, to) in changes.movedItems {
        view.moveItemAtIndexPath(
            NSIndexPath(forItem: from.itemIndex, inSection: from.sectionIndex),
            to: NSIndexPath(forItem: to.itemIndex, inSection: to.sectionIndex)
        )
    }
}