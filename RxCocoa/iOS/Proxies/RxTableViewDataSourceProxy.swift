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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
}

/**
     For more information take a look at `DelegateProxyType`.
 */
open class RxTableViewDataSourceProxy
    : DelegateProxy
    , UITableViewDataSource
    , DelegateProxyType {

    /**
     Typed parent object.
     */
    open weak fileprivate(set) var tableView: UITableView?
    
    fileprivate weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet

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
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }

    /**
    Required delegate method implementation.
    */
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    open override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let tableView = (object as! UITableView)

        return castOrFatalError(tableView.rx_createDataSourceProxy())
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    open override class func delegateAssociatedObjectTag() -> UnsafeRawPointer {
        return _pointer(&dataSourceAssociatedTag)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    open class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: UITableView = castOrFatalError(object)
        tableView.dataSource = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    open class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableView: UITableView = castOrFatalError(object)
        return tableView.dataSource
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    open override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: UITableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
