//
//  UISectionedViewType+RxAnimatedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 11/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

extension UITableView {
    public func rx_itemsAnimatedWithDataSource<
            DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource>,
            O: ObservableConvertibleType,
            Section: AnimatableSectionModelType
        where
            DataSource.Element == [Changeset<Section>],
            O.E == [Section]
        >
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
        return  { source in
            let differences = source.differentiateForSectionedView()
            return self.rx_itemsWithDataSource(dataSource)(source: differences)
        }
    }
}

extension UICollectionView {
    public func rx_itemsAnimatedWithDataSource<
            DataSource: protocol<RxCollectionViewDataSourceType, UICollectionViewDataSource>,
            O: ObservableConvertibleType,
            Section: AnimatableSectionModelType
        where
            DataSource.Element == [Changeset<Section>],
            O.E == [Section]
        >
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
        return { source in
            let differences = source.differentiateForSectionedView()
            return self.rx_itemsWithDataSource(dataSource)(source: differences)
        }
    }
}