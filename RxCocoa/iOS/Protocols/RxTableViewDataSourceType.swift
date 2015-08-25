//
//  RxTableViewDataSourceType.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

// Please take a look at `DelegateProxyType.swift`
public protocol RxTableViewDataSourceType /*: UITableViewDataSource*/ {
    typealias Element
    
    func tableView(tableView: UITableView, observedEvent: Event<Element>) -> Void
}