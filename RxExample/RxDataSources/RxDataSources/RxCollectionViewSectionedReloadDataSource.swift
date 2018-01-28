//
//  RxCollectionViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
import RxSwift
import RxCocoa

open class RxCollectionViewSectionedReloadDataSource<S: SectionModelType>
    : CollectionViewSectionedDataSource<S>
    , RxCollectionViewDataSourceType {
    
    public typealias Element = [S]

    open func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, element in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            dataSource.setSections(element)
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }.on(observedEvent)
    }
}
#endif
