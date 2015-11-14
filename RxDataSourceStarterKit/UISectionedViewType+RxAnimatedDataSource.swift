//
//  UISectionedView+RxAnimatedDataSource.swift
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
            S: SequenceType,
            O: ObservableConvertibleType,
            Section: protocol<SectionModelType, Hashable>
        where
            DataSource.Element == [Changeset<Section>],
            O.E == S,
            S.Generator.Element == Section,
            Section.Item: Hashable
        >
        (dataSource: DataSource)
        (source: O)
        -> Disposable  {
        let differences = source.differentiateForSectionedView()
        return self.rx_itemsWithDataSource(dataSource)(source: differences)
    }
}

extension UICollectionView {
    public func rx_itemsAnimatedWithDataSource<
            DataSource: protocol<RxCollectionViewDataSourceType, UICollectionViewDataSource>,
            S: SequenceType,
            O: ObservableConvertibleType,
            Section: protocol<SectionModelType, Hashable>
        where
            DataSource.Element == [Changeset<Section>],
            O.E == S,
            S.Generator.Element == Section,
            Section.Item: Hashable
        >
        (dataSource: DataSource)
        (source: O)
        -> Disposable  {
        let differences = source.differentiateForSectionedView()
        return self.rx_itemsWithDataSource(dataSource)(source: differences)
    }
}