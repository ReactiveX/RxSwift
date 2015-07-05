//
//  RxTableViewSectionedAnimatedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RxTableViewSectionedAnimatedDataSource<S: SectionModelType> : RxTableViewSectionedDataSource<S>
                                                                  , RxTableViewDataSourceType {
    typealias Element = [Changeset<S>]
    
    func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let boxedSections):
            for c in boxedSections.value {
                //println("Animating ==============================\n\(c)\n===============================\n")
                setSections(c.finalSections)
                tableView.performBatchUpdates(c)
            }
        case .Error(let error):
            #if DEBUG
                fatalError("Binding error to UI")
            #endif
        case .Completed:
            break
        }
    }
}