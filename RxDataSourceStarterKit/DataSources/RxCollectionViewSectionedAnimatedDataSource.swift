//
//  RxCollectionViewSectionedAnimatedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RxCollectionViewSectionedAnimatedDataSource<S: SectionModelType> : RxCollectionViewSectionedDataSource<S>
                                                                       , RxCollectionViewDataSourceType {
    typealias Element = [Changeset<S>]
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var set = false
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let boxedSections):
            for c in boxedSections.value {
                //println("Animating ==============================\n\(c)\n===============================\n")
                setSections(c.finalSections)
                
                if !set {
                    collectionView.reloadData()
                    set = true
                    return
                }
                collectionView.performBatchUpdates(c)
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