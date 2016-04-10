//
//  RxScrollViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

/**
 For more information take a look at `DelegateProxyType`.
*/
public class RxScrollViewDelegateProxy
    : DelegateProxy
    , UIScrollViewDelegate
    , DelegateProxyType {

    private var _contentOffsetSubject: ReplaySubject<CGPoint>?

    /**
     Typed parent object.
     */
    public weak private(set) var scrollView: UIScrollView?

    /**
     Optimized version used for observing content offset changes.
    */
    internal var contentOffsetSubject: Observable<CGPoint> {
        if _contentOffsetSubject == nil {
            let replaySubject = ReplaySubject<CGPoint>.create(bufferSize: 1)
            _contentOffsetSubject = replaySubject
            replaySubject.on(.Next(self.scrollView?.contentOffset ?? CGPointZero))
        }
        
        return _contentOffsetSubject!
    }

    /**
     Initializes `RxScrollViewDelegateProxy`

     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.scrollView = (parentObject as! UIScrollView)
        super.init(parentObject: parentObject)
    }
    
    // MARK: delegate methods

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if let contentOffset = _contentOffsetSubject {
            contentOffset.on(.Next(scrollView.contentOffset))
        }
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: delegate proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let scrollView = (object as! UIScrollView)
        
        return castOrFatalError(scrollView.rx_createDelegateProxy())
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let scrollView: UIScrollView = castOrFatalError(object)
        scrollView.delegate = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let scrollView: UIScrollView = castOrFatalError(object)
        return scrollView.delegate
    }
    
    deinit {
        if let contentOffset = _contentOffsetSubject {
            contentOffset.on(.Completed)
        }
    }
}

#endif
