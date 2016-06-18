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
    func numberOfSections(in tableView: UITableView) -> Int {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    public func numberOfSections(in tableView: UITableView) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).numberOfSections?(in: tableView) ?? 1
    }

    /**
    Required delegate method implementation.
    */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }

    /**
    Required delegate method implementation.
    */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
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
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: UITableView = castOrFatalError(object)
        tableView.dataSource = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableView: UITableView = castOrFatalError(object)
        return tableView.dataSource
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: UITableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
