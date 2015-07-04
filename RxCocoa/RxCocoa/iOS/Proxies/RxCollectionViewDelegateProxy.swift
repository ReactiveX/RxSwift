//
//  RxCollectionViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateProxyType.swift`
public class RxCollectionViewDelegateProxy : RxScrollViewDelegateProxy
                                           , UICollectionViewDelegate {
    
    public typealias ItemSelectedObserver = ObserverOf<ItemSelectedEvent<UICollectionView>>
    public typealias ItemSelectedDisposeKey = Bag<ItemSelectedObserver>.KeyType
    
    public let collectionView: UICollectionView
    
    var itemSelectedObservers: Bag<ItemSelectedObserver> = Bag()
    
    var collectionViewDelegate: UICollectionViewDelegate?
    
    public override init(view: UIView) {
        self.collectionView = view as! UICollectionView
        
        super.init(view: view)
    }
    
    public func addItemSelectedObserver(observer: ItemSelectedObserver) -> ItemSelectedDisposeKey {
        return itemSelectedObservers.put(observer)
    }
    
    public func removeItemSelectedObserver(key: ItemSelectedDisposeKey) {
        let element = itemSelectedObservers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    // delegate proxy
    
    override public class func setProxyToView(view: UIView, proxy: AnyObject) {
        let _: UICollectionViewDelegate = castOrFatalError(proxy)
        super.setProxyToView(view, proxy: proxy)
    }
    
    override public func setDelegate(delegate: AnyObject?) {
        let typedDelegate: UICollectionViewDelegate? = castOptionalOrFatalError(delegate)
        self.collectionViewDelegate = typedDelegate
        
        super.setDelegate(delegate)
    }
    
    // dispose
    
    public override var isDisposable: Bool {
        get {
            return super.isDisposable && self.itemSelectedObservers.count == 0
        }
    }
    
    deinit {
        if !isDisposable {
            handleVoidObserverResult(failure(rxError(RxCocoaError.InvalidOperation, "Something went wrong. Deallocating collection view delegate while there are still subscribed observers means that some subscription was left undisposed.")))
        }
    }
}