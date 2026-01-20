//
//  RxTableViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

/// For more information take a look at `DelegateProxyType`.
open class RxTableViewDelegateProxy:
    RxScrollViewDelegateProxy
{
    /// Typed parent object.
    public private(set) weak var tableView: UITableView?

    /// - parameter tableView: Parent object for delegate proxy.
    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init(scrollView: tableView)
    }
}

extension RxTableViewDelegateProxy: UITableViewDelegate {}

#endif
