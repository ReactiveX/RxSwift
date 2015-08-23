//
//  CoreDataEntityEvent.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

/*
import Foundation
import CoreData
#if !RX_NO_MODULE
import RxSwift
#endif

enum CoreDataEntityEvent : CustomStringConvertible {
    
    typealias SectionInfo = NSFetchedResultsSectionInfo
    
    case Snapshot(sections: [SectionInfo])
    
    case TransactionStarted
    case TransactionEnded
    
    case ItemMoved(item: NSManagedObject, sourceIndexPath: NSIndexPath, destinationIndexPath: NSIndexPath)
    case ItemInserted(item: NSManagedObject, newIndexPath: NSIndexPath)
    case ItemDeleted(withIndexPath: NSIndexPath)
    case ItemUpdated(item: NSManagedObject, atIndexPath: NSIndexPath)
    
    case SectionInserted(section: SectionInfo, newIndex: Int)
    case SectionDeleted(withIndex: Int)
    case SectionUpdated(section: SectionInfo, atIndex: Int)
    
    
    var description: String {
        get {
            switch self {
            case .Snapshot(sections: let snapshot):
                return "Snapshot(\(snapshot))"
            case TransactionStarted:
                return "TransactionStarted"
            case TransactionEnded:
                return "TransactionEnded"
            case ItemMoved(item: let item, sourceIndexPath: let sourceIndexPath, destinationIndexPath: let destinationIndexPath):
                return "ItemMoved(\(item), \(sourceIndexPath), \(destinationIndexPath))"
            case ItemInserted(item: let item, newIndexPath: let newIndexPath):
                return "ItemInserted(\(item), \(newIndexPath))"
            case ItemDeleted(withIndexPath: let indexPath):
                return "ItemDeleted(\(indexPath))"
            case ItemUpdated(item: let item, atIndexPath: let indexPath):
                return "ItemUpdated(\(item), \(indexPath))"
            case SectionInserted(section: let section, newIndex: let index):
                return "SectionInserted(\(section), \(index))"
            case SectionDeleted(withIndex: let index):
                return "SectionDeleted(\(index))"
            case SectionUpdated(section: let section, atIndex: let index):
                return "SectionUpdated(\(section), \(index))"
            }
        }
    }
}
*/