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

public class RxCollectionViewSectionedAnimatedDataSource<S: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<S>
    , RxCollectionViewDataSourceType {
    public typealias Element = [S]
    public var animationConfiguration = AnimationConfiguration()
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var dataSet = false

    public override init() {
        super.init()
    }
    
    public func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { dataSource, newSections in
            if !self.dataSet {
                self.dataSet = true
                dataSource.setSections(newSections)
                collectionView.reloadData()
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try differencesForSectionedView(oldSections, finalSections: newSections)

                        for difference in differences {
                            dataSource.setSections(difference.finalSections)

                            collectionView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                        }
                    }
                    catch let e {
                        rxDebugFatalError(e)
                        self.setSections(newSections)
                        collectionView.reloadData()
                    }
                }
            }
        }.on(observedEvent)
    }
}