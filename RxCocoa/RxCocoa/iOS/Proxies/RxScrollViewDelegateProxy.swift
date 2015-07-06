//
//  RxScrollViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

// Please take a look at `DelegateProxyType.swift`
class RxScrollViewDelegateProxy : DelegateProxy
                                , UIScrollViewDelegate
                                , DelegateProxyType {
    typealias ContentOffsetObserver = ObserverOf<CGPoint>
    typealias ContentOffsetDisposeKey = Bag<ContentOffsetObserver>.KeyType

    var contentOffsetObservers: Bag<ContentOffsetObserver>?
    
    unowned let scrollView: UIScrollView
    
    required init(parentObject: AnyObject) {
        self.scrollView = parentObject as! UIScrollView
        super.init(parentObject: parentObject)
    }
    
    // registering / unregistering observers
    
    func addContentOffsetObserver(observer: ContentOffsetObserver) -> ContentOffsetDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        if contentOffsetObservers == nil {
            contentOffsetObservers = Bag()
        }
        return contentOffsetObservers!.put(observer)
    }
    
    func removeContentOffsetObserver(key: ContentOffsetDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = contentOffsetObservers?.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }

    // delegate methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let contentOffsetObservers = contentOffsetObservers {
            dispatchNext(scrollView.contentOffset, contentOffsetObservers)
        }
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // delegate proxy
    
    override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let scrollView = object as! UIScrollView
        
        return castOrFatalError(scrollView.rx_createDelegateProxy())
    }

    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let collectionView: UIScrollView = castOrFatalError(object)
        collectionView.delegate = castOptionalOrFatalError(delegate)
    }
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let collectionView: UIScrollView = castOrFatalError(object)
        return collectionView.delegate
    }
}