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

class RxCollectionViewSectionedAnimatedDataSource<S: SectionModelType> : RxCollectionViewSectionedDataSource<S>, RxCollectionViewReactiveDataSourceType {
    typealias Element = [Changeset<S>]
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let boxedSections):
            for c in boxedSections.value {
                //println("Animating ==============================\n\(c)\n===============================\n")
                setSections(c.finalSections)
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