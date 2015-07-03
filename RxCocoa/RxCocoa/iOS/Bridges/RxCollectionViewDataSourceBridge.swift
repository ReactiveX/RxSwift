//
//  RxCollectionViewDataSourceBridge.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateBridgeType.swift`
public class RxCollectionViewDataSourceBridge : Delegate
                                              , UICollectionViewDataSource
                                              , DelegateBridgeType {
    public let collectionView: UICollectionView
    
    var dataSource: RxCollectionViewDataSourceType?
    
    public init(view: UICollectionView) {
        self.collectionView = view
        super.init()
    }
    
    // data source methods
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return dataSource!.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSectionsInCollectionView(collectionView) ?? 1
    }
    
    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return dataSource!.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
    
    // bridge
    
    public class func createBridgeForView(view: UIView) -> Self {
        let collectionView = view as! UICollectionView
        return castOrFatalError(collectionView.rx_createDataSourceBridge())
    }
    
    public class func getBridgeForView(view: UIView) -> Self? {
        let collectionView = view as! UICollectionView
        return castOptionalOrFatalError(collectionView.dataSource)
    }
    
    // tried using `Self` instead of Any object, didn't work out
    public class func setBridgeToView(view: UIView, bridge: AnyObject) {
        let collectionView = view as! UICollectionView
        collectionView.dataSource = castOptionalOrFatalError(bridge)
    }
    
    public func setDelegate(delegate: AnyObject?) {
        dataSource = castOptionalOrFatalError(delegate)
    }
    
    public func getDelegate() -> AnyObject? {
        return dataSource
    }
    
    
    // disposable
    
    override public var isDisposable: Bool {
        get {
            return super.isDisposable
                && self.dataSource == nil
        }
    }
    
    override public func dispose() {
        super.dispose()
        assert(collectionView.dataSource == nil || collectionView.dataSource === self)
        collectionView.dataSource = nil
    }
    
    deinit {
        if !isDisposable {
            handleVoidObserverResult(failure(rxError(RxCocoaError.InvalidOperation, "Something went wrong. Deallocating collection view delegate while there are still subscribed observers means that some subscription was left undisposed.")))
        }
    }
}