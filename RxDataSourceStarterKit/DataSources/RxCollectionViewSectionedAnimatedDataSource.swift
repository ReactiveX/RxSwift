//
//  RxCollectionViewSectionedAnimatedDataSource.swift
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

class RxCollectionViewSectionedAnimatedDataSource<S: SectionModelType> : RxCollectionViewSectionedDataSource<S>
                                                                       , RxCollectionViewDataSourceType {
    typealias Element = [Changeset<S>]
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var set = false
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let element):
            for c in element {
                //print("Animating ==============================\n\(c)\n===============================\n")
                
                if !set {
                    setSections(c.finalSections)
                    collectionView.reloadData()
                    set = true
                    return
                }
                setSections(c.finalSections)
                collectionView.performBatchUpdates(c)
            }
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}