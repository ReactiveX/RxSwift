//
//  RxTableViewSectionedAnimatedDataSource.swift
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

public class RxTableViewSectionedAnimatedDataSource<S: SectionModelType>
    : RxTableViewSectionedDataSource<S>
    , RxTableViewDataSourceType {
    
    public typealias Element = [Changeset<S>]
    public var animationConfiguration: AnimationConfiguration? = nil

    public override init() {
        super.init()
    }

    public func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, element in
            for c in element {
                dataSource.setSections(c.finalSections)
                if c.reloadData {
                    tableView.reloadData()
                }
                else {
                  tableView.performBatchUpdates(c, animationConfiguration: self.animationConfiguration)
                }
            }
        }.on(observedEvent)
    }
}