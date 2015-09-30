//
//  RxCollectionViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

// objc monkey business
class _RxCollectionViewReactiveArrayDataSource: NSObject, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func _collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _collectionView(collectionView, numberOfItemsInSection: section)
    }

    func _collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return rxAbstractMethod()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return _collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
}

class RxCollectionViewReactiveArrayDataSourceSequenceWrapper<S: SequenceType> : RxCollectionViewReactiveArrayDataSource<S.Generator.Element>
                                                                              , RxCollectionViewDataSourceType {
    typealias Element = S

    override init(cellFactory: CellFactory) {
        super.init(cellFactory: cellFactory)
    }
    
    func collectionView(collectionView: UICollectionView, observedEvent: Event<S>) {
        switch observedEvent {
        case .Next(let value):
            super.collectionView(collectionView, observedElements: Array(value))
            self.itemModels = Array(value)
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}


// Please take a look at `DelegateProxyType.swift`
class RxCollectionViewReactiveArrayDataSource<Element> : _RxCollectionViewReactiveArrayDataSource {
    
    typealias CellFactory = (UICollectionView, Int, Element) -> UICollectionViewCell
    
    var itemModels: [Element]? = nil
    
    func modelAtIndex(index: Int) -> Element? {
        return itemModels?[index]
    }
    
    var cellFactory: CellFactory
    
    init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
    }
    
    // data source
    
    override func _collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    override func _collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellFactory(collectionView, indexPath.item, itemModels![indexPath.item])
    }
    
    // reactive
    
    func collectionView(collectionView: UICollectionView, observedElements: [Element]) {
        self.itemModels = observedElements
        
        collectionView.reloadData()
    }
}

#endif
