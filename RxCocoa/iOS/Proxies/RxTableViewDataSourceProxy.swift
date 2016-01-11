//
//  RxTableViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

class TableViewDataSourceNotSet
    : NSObject
    , UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
}

/**
     For more information take a look at `DelegateProxyType`.
 */
public class RxTableViewDataSourceProxy
    : DelegateProxy
    , UITableViewDataSource
    , DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak private(set) var tableView: UITableView?
    
    private weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet

    /**
     Initializes `RxTableViewDataSourceProxy`

     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! UITableView)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    /**
    Required delegate method implementation.
    */
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).numberOfSectionsInTableView?(tableView) ?? 1
    }

    /**
    Required delegate method implementation.
    */
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }

    /**
    Required delegate method implementation.
    */
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    // MARK: proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let tableView = (object as! UITableView)

        return castOrFatalError(tableView.rx_createDataSourceProxy())
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _pointer(&dataSourceAssociatedTag)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let collectionView: UITableView = castOrFatalError(object)
        collectionView.dataSource = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let collectionView: UITableView = castOrFatalError(object)
        return collectionView.dataSource
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: UITableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
