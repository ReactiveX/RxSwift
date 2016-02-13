//
//  RxCollectionViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class RxCollectionViewSectionedReloadDataSource<S: SectionModelType> : RxCollectionViewSectionedDataSource<S>
                                                                     , RxCollectionViewDataSourceType {
    typealias Element = [S]
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, element in
            dataSource.setSections(element)
            collectionView.reloadData()
        }.on(observedEvent)
    }
}