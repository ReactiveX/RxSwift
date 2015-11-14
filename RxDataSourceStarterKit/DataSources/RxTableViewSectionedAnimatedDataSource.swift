//
//  RxTableViewSectionedAnimatedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class RxTableViewSectionedAnimatedDataSource<S: SectionModelType> : RxTableViewSectionedDataSource<S>
                                                                  , RxTableViewDataSourceType {
    typealias Element = [Changeset<S>]
    
    func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let element):
            for c in element {
                //print("Animating ==============================\n\(c)\n===============================\n")
                setSections(c.finalSections)
                if c.reloadData {
                    tableView.reloadData()
                }
                else {
                    tableView.performBatchUpdates(c)
                }
            }
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}