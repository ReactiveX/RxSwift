//
//  TableViewSectionedDataSource.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxCocoa
#endif

// objc monkey business
public class _TableViewSectionedDataSource
    : NSObject
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
    
    func _tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return _tableView(tableView, canEditRowAtIndexPath: indexPath)
    }
    
    func _tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return _tableView(tableView, canMoveRowAtIndexPath: indexPath)
    }
    
    func _sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return _sectionIndexTitlesForTableView(tableView)
    }
    
    func _tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 0
    }

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return _tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    }
    
}

public class RxTableViewSectionedDataSource<S: SectionModelType>
    : _TableViewSectionedDataSource
    , SectionedViewDataSourceType {
    
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (RxTableViewSectionedDataSource<S>, UITableView, NSIndexPath, I) -> UITableViewCell
    
    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    private var _sectionModels: [SectionModelSnapshot] = []

    public var sectionModels: [S] {
        return _sectionModels.map { $0.model }
    }

    public func sectionAtIndex(section: Int) -> S {
        return self._sectionModels[section].model
    }

    public func itemAtIndexPath(indexPath: NSIndexPath) -> I {
        return self._sectionModels[indexPath.section].items[indexPath.item]
    }

    public func modelAtIndexPath(indexPath: NSIndexPath) throws -> Any {
        return itemAtIndexPath(indexPath)
    }

    public func setSections(sections: [S]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }


    public var configureCell: CellFactory! = nil
    
    public var titleForHeaderInSection: ((RxTableViewSectionedDataSource<S>, section: Int) -> String?)?
    public var titleForFooterInSection: ((RxTableViewSectionedDataSource<S>, section: Int) -> String?)?
    
    public var canEditRowAtIndexPath: ((RxTableViewSectionedDataSource<S>, indexPath: NSIndexPath) -> Bool)?
    public var canMoveRowAtIndexPath: ((RxTableViewSectionedDataSource<S>, indexPath: NSIndexPath) -> Bool)?
    
    public var sectionIndexTitles: ((RxTableViewSectionedDataSource<S>) -> [String]?)?
    public var sectionForSectionIndexTitle:((RxTableViewSectionedDataSource<S>, title: String, index: Int) -> Int)?
    
    public var rowAnimation: UITableViewRowAnimation = .Automatic
    
    public override init() {
        super.init()
        self.configureCell = { [weak self] _ in
            if let strongSelf = self {
                precondition(false, "There is a minor problem. `cellFactory` property on \(strongSelf) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            }
            
            return (nil as UITableViewCell!)!
        }
    }
    
    // UITableViewDataSource
    
    override func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _sectionModels.count
    }
    
    override func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    override func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return configureCell(self, tableView, indexPath, itemAtIndexPath(indexPath))
    }
    
    override func _tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection?(self, section: section)
    }
    
    override func _tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection?(self, section: section)
    }
    
    override func _tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let canEditRow = canEditRowAtIndexPath?(self, indexPath: indexPath) else {
            return super._tableView(tableView, canMoveRowAtIndexPath: indexPath)
        }
        
        return canEditRow
    }
   
    override func _tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let canMoveRow = canMoveRowAtIndexPath?(self, indexPath: indexPath) else {
            return super._tableView(tableView, canMoveRowAtIndexPath: indexPath)
        }
        
        return canMoveRow
    }
    
    override func _sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        guard let titles = sectionIndexTitles?(self) else {
            return super._sectionIndexTitlesForTableView(tableView)
        }
        
        return titles
    }
    
    override func _tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        guard let section  = sectionForSectionIndexTitle?(self, title: title, index: index) else {
            return super._tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
        }
        
        return section
    }
    
}
