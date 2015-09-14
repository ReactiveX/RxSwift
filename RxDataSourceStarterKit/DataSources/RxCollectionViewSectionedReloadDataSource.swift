//
//  RxCollectionViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
        switch observedEvent {
        case .Next(let element):
            setSections(element)
            collectionView.reloadData()
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}