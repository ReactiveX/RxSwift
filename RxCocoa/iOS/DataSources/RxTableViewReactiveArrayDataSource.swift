//
//  RxTableViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/26/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

// objc monkey business
class _RxTableViewReactiveArrayDataSource
    : NSObject
    , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    func _tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }

    private func _tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rxAbstractMethod()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAt: indexPath)
    }
}


class RxTableViewReactiveArrayDataSourceSequenceWrapper<S: Sequence>
    : RxTableViewReactiveArrayDataSource<S.Iterator.Element>
    , RxTableViewDataSourceType {
    typealias Element = S

    override init(cellFactory: CellFactory) {
        super.init(cellFactory: cellFactory)
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<S>) {
        UIBindingObserver(UIElement: self) { tableViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            tableViewDataSource.tableView(tableView, observedElements: sections)
        }.on(observedEvent)
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxTableViewReactiveArrayDataSource<Element>
    : _RxTableViewReactiveArrayDataSource
    , SectionedViewDataSourceType {
    typealias CellFactory = (UITableView, Int, Element) -> UITableViewCell
    
    var itemModels: [Element]? = nil
    
    func modelAtIndex(_ index: Int) -> Element? {
        return itemModels?[index]
    }

    func modelAtIndexPath(_ indexPath: IndexPath) throws -> Any {
        precondition((indexPath as NSIndexPath).section == 0)
        guard let item = itemModels?[(indexPath as NSIndexPath).item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }

    let cellFactory: CellFactory
    
    init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
    }
    
    override func _tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    override func _tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory(tableView, (indexPath as NSIndexPath).item, itemModels![(indexPath as NSIndexPath).row])
    }
    
    // reactive
    
    func tableView(_ tableView: UITableView, observedElements: [Element]) {
        self.itemModels = observedElements
        
        tableView.reloadData()
    }
}

#endif
