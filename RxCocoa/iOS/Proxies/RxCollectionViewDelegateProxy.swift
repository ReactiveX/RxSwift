//
//  RxCollectionViewDelegateProxy.swift
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

/// For more information take a look at `DelegateProxyType`.
open class RxCollectionViewDelegateProxy
    : RxScrollViewDelegateProxy
    , UICollectionViewDelegate
    , UICollectionViewDelegateFlowLayout {

    /// Typed parent object.
    public weak private(set) var collectionView: UICollectionView?

    /// Initializes `RxCollectionViewDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public init(parentObject: UICollectionView) {
        self.collectionView = parentObject
        super.init(parentObject: parentObject)
    }
}

#endif
