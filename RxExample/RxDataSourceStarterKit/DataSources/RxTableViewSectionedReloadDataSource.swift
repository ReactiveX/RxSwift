//
//  RxTableViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

/**
 Code for reactive data sources is packed in [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) project.
 */
class RxTableViewSectionedReloadDataSource<S: SectionModelType> : RxTableViewSectionedDataSource<S>
                                                                , RxTableViewDataSourceType {
    typealias Element = [S]
    
    func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, element in
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
}