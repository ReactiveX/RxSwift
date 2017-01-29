//
//  RxTableViewDelegateProxy.swift
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

/// For more information take a look at `DelegateProxyType`.
public class RxTableViewDelegateProxy
    : RxScrollViewDelegateProxy
    , UITableViewDelegate {


    /// Typed parent object.
    public weak private(set) var tableView: UITableView?

    /// Initializes `RxTableViewDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.tableView = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

}

#endif
