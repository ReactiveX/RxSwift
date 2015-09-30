//
//  RxCollectionViewDataSourceProxy.swift
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

let collectionViewDataSourceNotSet = CollectionViewDataSourceNotSet()

class CollectionViewDataSourceNotSet : NSObject
                                     , UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
}

// Please take a look at `DelegateProxyType.swift`
class RxCollectionViewDataSourceProxy : DelegateProxy
                                      , UICollectionViewDataSource
                                      , DelegateProxyType {
    
    unowned let collectionView: UICollectionView
    
    unowned var dataSource: UICollectionViewDataSource = collectionViewDataSourceNotSet
    
    required init(parentObject: AnyObject) {
        self.collectionView = parentObject as! UICollectionView
        super.init(parentObject: parentObject)
    }
    
    // data source methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return dataSource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    // proxy
    
    override class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _pointer(&dataSourceAssociatedTag)
    }
 
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let collectionView: UICollectionView = castOrFatalError(object)
        collectionView.dataSource = castOptionalOrFatalError(delegate)
    }
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let collectionView: UICollectionView = castOrFatalError(object)
        return collectionView.dataSource
    }
    
    override func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let dataSource: UICollectionViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        self.dataSource = dataSource ?? collectionViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
