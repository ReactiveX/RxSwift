//
//  RxTableViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

final class TableViewDataSourceNotSet
    : NSObject
    , UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rxAbstractMethod(message: dataSourceNotSet)
    }
}

/// For more information take a look at `DelegateProxyType`.
open class RxTableViewDataSourceProxy
    : DelegateProxy<UITableView, UITableViewDataSource>
    , DelegateProxyType 
    , UITableViewDataSource {

    public static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: RxTableViewDataSourceProxy.self)
    }

    /// Typed parent object.
    public weak fileprivate(set) var tableView: UITableView?

    fileprivate weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet

    /// Initializes `RxTableViewDataSourceProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: ParentObject) {
        self.tableView = parentObject
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    /// Required delegate method implementation.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }

    /// Required delegate method implementation.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: proxy

    /// For more information take a look at `DelegateProxyType`.
    open override class func delegateAssociatedObjectTag() -> UnsafeRawPointer {
        return dataSourceAssociatedTag
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: UITableViewDataSource?, toObject object: ParentObject) {
        object.dataSource = delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegate(for object: ParentObject) -> UITableViewDataSource? {
        return object.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    open override func setForwardToDelegate(_ forwardToDelegate: UITableViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate  ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

}

#endif
