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
    @available(*, deprecated=0.7, renamed="rx_itemsWithDataSource", message="You can just use normal `rx_itemsWithDataSource` extension.")
    public func rx_itemsAnimatedWithDataSource<
            DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource>,
            S: SequenceType,
            O: ObservableType
        where
            DataSource.Element == S,
            O.E == S,
            S.Generator.Element: AnimatableSectionModelType
        >
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
        return  { source in
            return self.rx_itemsWithDataSource(dataSource)(source: source)
        }
    }
}

extension UICollectionView {
    @available(*, deprecated=0.7, renamed="rx_itemsWithDataSource", message="You can just use normal `rx_itemsWithDataSource` extension.")
    public func rx_itemsAnimatedWithDataSource<
            DataSource: protocol<RxCollectionViewDataSourceType, UICollectionViewDataSource>,
            S: SequenceType,
            O: ObservableType
        where
            DataSource.Element == S,
            O.E == S,
            S.Generator.Element: AnimatableSectionModelType
        >
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
        return { source in
            return self.rx_itemsWithDataSource(dataSource)(source: source)
        }
    }
}