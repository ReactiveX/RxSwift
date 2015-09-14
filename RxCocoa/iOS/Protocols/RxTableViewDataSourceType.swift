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

/**
Marks data source as `UITableView` reactive data source enabling it to be used with one of the `bindTo` methods.
*/
public protocol RxTableViewDataSourceType /*: UITableViewDataSource*/ {
    
    /**
    Type of elements that can be bound to table view.
    */
    typealias Element
    
    /**
    New observable sequence event observed.
    
    - parameter tableView: Bound table view.
    - parameter observedEvent: Event
    */
    func tableView(tableView: UITableView, observedEvent: Event<Element>) -> Void
}