//
//  RxTableViewDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

// objc monkey business
public class _RxTableViewSectionedDataSource : NSObject
                                             , UITableViewDataSource {
    
    func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _numberOfSectionsInTableView(tableView)
    }

    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }

    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return (nil as UITableViewCell?)!
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    func _tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _tableView(tableView, titleForHeaderInSection: section)
    }

    func _tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return _tableView(tableView, titleForFooterInSection: section)
    }
}

public class RxTableViewSectionedDataSource<S: SectionModelType> : _RxTableViewSectionedDataSource {
    
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (UITableView, NSIndexPath, I) -> UITableViewCell
    
    public typealias IncrementalUpdateObserver = AnyObserver<Changeset<S>>
    
    public typealias IncrementalUpdateDisposeKey = Bag<IncrementalUpdateObserver>.KeyType
    
    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    var sectionModels: [SectionModelSnapshot] = []

    public func sectionAtIndex(section: Int) -> S {
        return self.sectionModels[section].model
    }

    public func itemAtIndexPath(indexPath: NSIndexPath) -> I {
        return self.sectionModels[indexPath.section].items[indexPath.item]
    }

    var incrementalUpdateObservers: Bag<IncrementalUpdateObserver> = Bag()
    
    public func setSections(sections: [S]) {
        self.sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    public var cellFactory: CellFactory! = nil
    
    public var titleForHeaderInSection: ((section: Int) -> String)?
    public var titleForFooterInSection: ((section: Int) -> String)?
    
    public var rowAnimation: UITableViewRowAnimation = .Automatic
    
    public override init() {
        super.init()
        self.cellFactory = { [weak self] _ in
            if let strongSelf = self {
                precondition(false, "There is a minor problem. `cellFactory` property on \(strongSelf) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            }
            
            return (nil as UITableViewCell!)!
        }
    }
    
    // observers
    
    public func addIncrementalUpdatesObserver(observer: IncrementalUpdateObserver) -> IncrementalUpdateDisposeKey {
        return incrementalUpdateObservers.insert(observer)
    }
    
    public func removeIncrementalUpdatesObserver(key: IncrementalUpdateDisposeKey) {
        let element = incrementalUpdateObservers.removeKey(key)
        precondition(element != nil, "Element removal failed")
    }
    
    // UITableViewDataSource
    
    override func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionModels.count
    }
    
    override func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].items.count
    }
    
    override func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        precondition(indexPath.item < sectionModels[indexPath.section].items.count)
        
        return cellFactory(tableView, indexPath, itemAtIndexPath(indexPath))
    }
    
    override func _tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection?(section: section)
    }
    
    override func _tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection?(section: section)
    }
    
}