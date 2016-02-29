//
//  RxCollectionViewSectionedAnimatedDataSource.swift
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

class RxCollectionViewSectionedAnimatedDataSource<S: SectionModelType> : RxCollectionViewSectionedDataSource<S>
                                                                       , RxCollectionViewDataSourceType {
    typealias Element = [Changeset<S>]
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var set = false
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { ds, element in
            for c in element {
                if !ds.set {
                    ds.setSections(c.finalSections)
                    collectionView.reloadData()
                    ds.set = true
                    return
                }
                ds.setSections(c.finalSections)
                collectionView.performBatchUpdates(c)
            }
        }.on(observedEvent)
    }
}