//
//  RxScrollViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

// Please take a look at `DelegateProxyType.swift`
class RxScrollViewDelegateProxy : DelegateProxy
                                , UIScrollViewDelegate
                                , DelegateProxyType {
    private var _contentOffsetSubject: ReplaySubject<CGPoint>?

    weak var scrollView: UIScrollView?
    
    var contentOffsetSubject: Observable<CGPoint> {
        if _contentOffsetSubject == nil {
            let replaySubject = ReplaySubject<CGPoint>.create(bufferSize: 1)
            _contentOffsetSubject = replaySubject
            replaySubject.on(.Next(self.scrollView?.contentOffset ?? CGPointZero))
        }
        
        return _contentOffsetSubject!
    }
    
    required init(parentObject: AnyObject) {
        self.scrollView = (parentObject as! UIScrollView)
        super.init(parentObject: parentObject)
    }
    
    // delegate methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let contentOffset = _contentOffsetSubject {
            contentOffset.on(.Next(scrollView.contentOffset))
        }
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // delegate proxy
    
    override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let scrollView = (object as! UIScrollView)
        
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
    
    deinit {
        if let contentOffset = _contentOffsetSubject {
            contentOffset.on(.Completed)
        }
    }
}

#endif
