//
//  RxTableViewReactiveArrayDataSource.swift
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

// objc monkey business
class _RxTableViewReactiveArrayDataSource: NSObject, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
   
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }

    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return rxAbstractMethod()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxTableViewReactiveArrayDataSource<ElementType> : _RxTableViewReactiveArrayDataSource
                                                      , RxTableViewDataSourceType {
    typealias Element = [ElementType]
    
    typealias CellFactory = (UITableView, Int, ElementType) -> UITableViewCell
    
    var itemModels: [ElementType]? = nil
    
    func modelAtIndex(index: Int) -> ElementType? {
        return itemModels?[index]
    }
    
    let cellFactory: CellFactory
    
    init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
    }
    
    override func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    override func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellFactory(tableView, indexPath.item, itemModels![indexPath.row])
    }
    
    // reactive
    
    func tableView(tableView: UITableView, observedEvent: Event<[ElementType]>) {
        switch observedEvent {
        case .Next(let boxedNext):
            self.itemModels = boxedNext.value
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
        
        tableView.reloadData()
    }
}