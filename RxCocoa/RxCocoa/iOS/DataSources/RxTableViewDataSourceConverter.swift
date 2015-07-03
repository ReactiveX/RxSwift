//
//  RxTableViewDataSourceConverter.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxTableViewDataSourceConverter : RxTableViewDataSourceType
                                            , DelegateConverterType {
    
    unowned let dataSource: UITableViewDataSource
    let strongDataSource: UITableViewDataSource?
    
    public init(dataSource: UITableViewDataSource, retainDataSource: Bool) {
    #if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
    #endif
        self.strongDataSource = retainDataSource ? dataSource : nil
        self.dataSource = dataSource
    }
    
    // converter
    
    public var targetDelegate: NSObjectProtocol? {
        get {
            return dataSource
        }
    }
    
    // data source
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource.numberOfSectionsInTableView?(tableView) ?? 1
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataSource.tableView?(tableView, titleForHeaderInSection: section)
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.dataSource.tableView?(tableView, titleForFooterInSection: section)
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.dataSource.tableView?(tableView, canEditRowAtIndexPath: indexPath) ?? false
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.dataSource.tableView?(tableView, canMoveRowAtIndexPath: indexPath) ?? false
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]!  {
        return self.dataSource.sectionIndexTitlesForTableView?(tableView)
    }
    
    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.dataSource.tableView?(tableView, sectionForSectionIndexTitle: title, atIndex: index) ?? 0
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.dataSource.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.dataSource.tableView?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
    
    deinit {
        #if TRACE_RESOURCES
            OSAtomicDecrement32(&resourceCount)
        #endif
    }
}