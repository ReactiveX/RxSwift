//
//  RxTableViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxTableViewReactiveArrayDataSource<ElementType> : RxTableViewNopDataSource, RxTableViewReactiveDataSourceType {
    typealias Element = [ElementType]
    
    typealias CellFactory = (UITableView, NSIndexPath, ElementType) -> UITableViewCell
    
    var itemModels: [ElementType]? = nil
    
    public func modelAtIndex(index: Int) -> ElementType? {
        return itemModels?[index]
    }
    
    let cellFactory: CellFactory
    
    init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cellFactory(tableView, indexPath, itemModels![indexPath.row])
    }
    
    // reactive
    
    public func tableView(tableView: UITableView, observedEvent: Event<[ElementType]>) {
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