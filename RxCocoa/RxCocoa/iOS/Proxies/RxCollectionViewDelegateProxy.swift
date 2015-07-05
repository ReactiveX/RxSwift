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

let collectionViewDelegateNotSet = CollectionViewDelegateNotSet()

class CollectionViewDelegateNotSet : NSObject
                                   , UICollectionViewDelegate {
}

// Please take a look at `DelegateProxyType.swift`
class RxCollectionViewDelegateProxy : RxScrollViewDelegateProxy
                                    , UICollectionViewDelegate {
    
    typealias ItemSelectedObserver = ObserverOf<NSIndexPath>
    typealias ItemSelectedDisposeKey = Bag<ItemSelectedObserver>.KeyType
    
    unowned let collectionView: UICollectionView
    
    var itemSelectedObservers: Bag<ItemSelectedObserver> = Bag()
    
    required init(parentObject: AnyObject) {
        self.collectionView = parentObject as! UICollectionView
        
        super.init(parentObject: parentObject)
    }
    
    func addItemSelectedObserver(observer: ItemSelectedObserver) -> ItemSelectedDisposeKey {
        return itemSelectedObservers.put(observer)
    }
    
    func removeItemSelectedObserver(key: ItemSelectedDisposeKey) {
        let element = itemSelectedObservers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
}