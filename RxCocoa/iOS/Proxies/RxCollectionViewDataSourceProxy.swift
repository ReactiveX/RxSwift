//
//  RxCollectionViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

let collectionViewDataSourceNotSet = CollectionViewDataSourceNotSet()

class CollectionViewDataSourceNotSet
    : NSObject
    , UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
}

/**
     For more information take a look at `DelegateProxyType`.
 */
public class RxCollectionViewDataSourceProxy
    : DelegateProxy
    , UICollectionViewDataSource
    , DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak private(set) var collectionView: UICollectionView?
    
    private weak var _requiredMethodsDataSource: UICollectionViewDataSource? = collectionViewDataSourceNotSet

    /**
     Initializes `RxCollectionViewDataSourceProxy`

     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.collectionView = (parentObject as! UICollectionView)
        super.init(parentObject: parentObject)
    }
    
    // MARK: delegate

    /**
    Required delegate method implementation.
    */
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? collectionViewDataSourceNotSet).collectionView(collectionView, numberOfItemsInSection: section) ?? 0
    }
    
    /**
     Required delegate method implementation.
     */
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return (_requiredMethodsDataSource ?? collectionViewDataSourceNotSet).collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    // MARK: proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let collectionView = (object as! UICollectionView)

        return castOrFatalError(collectionView.rx_createDataSourceProxy())
    }

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _pointer(&dataSourceAssociatedTag)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let collectionView: UICollectionView = castOrFatalError(object)
        collectionView.dataSource = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let collectionView: UICollectionView = castOrFatalError(object)
        return collectionView.dataSource
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: UICollectionViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? collectionViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
