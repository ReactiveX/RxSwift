//
//  RxCollectionViewDataSourceConverter.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxCollectionViewDataSourceConverter : RxCollectionViewDataSourceType
                                                 , DelegateConverterType {
    
    unowned let dataSource: UICollectionViewDataSource
    let strongDataSource: UICollectionViewDataSource?
    
    public init(dataSource: UICollectionViewDataSource, retainDataSource: Bool) {
        #if TRACE_RESOURCES
            OSAtomicIncrement32(&resourceCount)
        #endif
        self.strongDataSource = retainDataSource ? dataSource : nil
        self.dataSource = dataSource
    }
    
    // converter
    
    public var targetDelegate: NSObjectProtocol? {
        get {
            return dataSource
        }
    }
    
    // copied methods from UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return dataSource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSectionsInCollectionView?(collectionView) ?? 1
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return dataSource.collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath) ?? rxAbstractMethod()
    }
    
    deinit {
        #if TRACE_RESOURCES
            OSAtomicDecrement32(&resourceCount)
        #endif
    }
}