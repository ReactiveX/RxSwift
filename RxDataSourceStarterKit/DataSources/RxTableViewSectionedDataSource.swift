//
//  RxTableViewDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

public class RxTableViewSectionedDataSource<S: SectionModelType> : RxTableViewNopDataSource {//<IncrementalUpdateEvent<SectionModel<S, I>>> {
    
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (UITableView, NSIndexPath, Section, I) -> UITableViewCell
    
    public typealias IncrementalUpdateObserver = ObserverOf<Changeset<S>>
    
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
                precondition(false, "There is a minor problem. `cellFactory` property on \(strongSelf) was not set. Please set it manually, or use one of the `rx_subscribeTo` methods.")
            }
            
            return (nil as UITableViewCell!)!
        }
    }
    
    // observers
    
    public func addIncrementalUpdatesObserver(observer: IncrementalUpdateObserver) -> IncrementalUpdateDisposeKey {
        return incrementalUpdateObservers.put(observer)
    }
    
    public func removeIncrementalUpdatesObserver(key: IncrementalUpdateDisposeKey) {
        let element = incrementalUpdateObservers.removeKey(key)
        precondition(element != nil, "Element removal failed")
    }
    
    // UITableViewDataSource
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionModels.count
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].items.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        precondition(indexPath.item < sectionModels[indexPath.section].items.count)
        
        let item = indexPath.item
        let section = sectionModels[indexPath.section]
        return cellFactory(tableView, indexPath, section.model, section.items[item])
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection?(section: section)
    }
    
    public override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection?(section: section)
    }
    
}