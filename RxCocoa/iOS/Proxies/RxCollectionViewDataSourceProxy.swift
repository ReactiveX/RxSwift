//
//  RxCollectionViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

let collectionViewDataSourceNotSet = CollectionViewDataSourceNotSet()

final class CollectionViewDataSourceNotSet
    : NSObject
    , UICollectionViewDataSource {


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        rxAbstractMethod(message: dataSourceNotSet)
    }
    
}

/// For more information take a look at `DelegateProxyType`.
public class RxCollectionViewDataSourceProxy
    : DelegateProxy
    , UICollectionViewDataSource
    , DelegateProxyType {

    /// Typed parent object.
    public weak private(set) var collectionView: UICollectionView?

    private weak var _requiredMethodsDataSource: UICollectionViewDataSource? = collectionViewDataSourceNotSet

    /// Initializes `RxCollectionViewDataSourceProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.collectionView = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }
    
    // MARK: delegate

    /// Required delegate method implementation.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? collectionViewDataSourceNotSet).collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    /// Required delegate method implementation.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (_requiredMethodsDataSource ?? collectionViewDataSourceNotSet).collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let collectionView: UICollectionView = castOrFatalError(object)
        return collectionView.createRxDataSourceProxy()
    }

    /// For more information take a look at `DelegateProxyType`.
    public override class func delegateAssociatedObjectTag() -> UnsafeRawPointer {
        return dataSourceAssociatedTag
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let collectionView: UICollectionView = castOrFatalError(object)
        collectionView.dataSource = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let collectionView: UICollectionView = castOrFatalError(object)
        return collectionView.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: UICollectionViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? collectionViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
