//
//  RxTableViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

class TableViewDataSourceNotSet : NSObject
                                , UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return rxAbstractMethodWithMessage(dataSourceNotSet)
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxTableViewDataSourceProxy : DelegateProxy
                                 , UITableViewDataSource
                                 , DelegateProxyType {
    
    unowned let tableView: UITableView
    
    unowned var dataSource: UITableViewDataSource = tableViewDataSourceNotSet
    
    required init(parentObject: AnyObject) {
        self.tableView = parentObject as! UITableView
        super.init(parentObject: parentObject)
    }

    // data source delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource.numberOfSectionsInTableView?(tableView) ?? 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    // proxy
    
    override class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _pointer(&dataSourceAssociatedTag)
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let collectionView: UITableView = castOrFatalError(object)
        collectionView.dataSource = castOptionalOrFatalError(delegate)
    }
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let collectionView: UITableView = castOrFatalError(object)
        return collectionView.dataSource
    }
    
    override func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let dataSource: UITableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        self.dataSource = dataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
