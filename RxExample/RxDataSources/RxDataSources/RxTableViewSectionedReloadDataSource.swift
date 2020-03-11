//
//  RxTableViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
import Foundation
import UIKit
import RxSwift
import RxCocoa

open class RxTableViewSectionedReloadDataSource<Section: SectionModelType>
    : TableViewSectionedDataSource<Section>
    , RxTableViewDataSourceType {
    public typealias Element = [Section]

    open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, element in
            #if DEBUG
                self.dataSourceBound = true
            #endif
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
}
#endif
