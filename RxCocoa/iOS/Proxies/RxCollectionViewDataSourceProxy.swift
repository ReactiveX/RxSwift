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
open class RxCollectionViewDataSourceProxy
    : DelegateProxy<UICollectionView, UICollectionViewDataSource>
    , DelegateProxyType 
    , UICollectionViewDataSource {

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxCollectionViewDataSourceProxy(parentObject: $0) }
    }

    /// Typed parent object.
    public weak private(set) var collectionView: UICollectionView?

    private weak var _requiredMethodsDataSource: UICollectionViewDataSource? = collectionViewDataSourceNotSet

    /// Initializes `RxCollectionViewDataSourceProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public override init(parentObject: ParentObject) {
        self.collectionView = parentObject
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
    open override class func setCurrentDelegate(_ delegate: UICollectionViewDataSource?, toObject object: ParentObject) {
        object.dataSource = delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegate(for object: ParentObject) -> UICollectionViewDataSource? {
        return object.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    open override func setForwardToDelegate(_ forwardToDelegate: UICollectionViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? collectionViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
