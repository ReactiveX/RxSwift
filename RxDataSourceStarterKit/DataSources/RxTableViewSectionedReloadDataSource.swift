//
//  RxTableViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RxTableViewSectionedReloadDataSource<S: SectionModelType> : RxTableViewSectionedDataSource<S>, RxTableViewReactiveDataSourceType {
    typealias Element = [S]
    
    func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let boxedSections):
            setSections(boxedSections.value)
            tableView.reloadData()
        case .Error(let error):
        #if DEBUG
            fatalError("Binding error to UI")
        #endif
        case .Completed:
            break
        }
    }
}