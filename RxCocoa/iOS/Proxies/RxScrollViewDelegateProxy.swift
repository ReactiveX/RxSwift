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

/// For more information take a look at `DelegateProxyType`.
public class RxScrollViewDelegateProxy
    : DelegateProxy
    , UIScrollViewDelegate
    , DelegateProxyType {

    fileprivate var _contentOffsetSubject: ReplaySubject<CGPoint>?

    /// Typed parent object.
    public weak fileprivate(set) var scrollView: UIScrollView?

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetSubject: Observable<CGPoint> {
        if _contentOffsetSubject == nil {
            let replaySubject = ReplaySubject<CGPoint>.create(bufferSize:1)
            _contentOffsetSubject = replaySubject
            replaySubject.on(.next(self.scrollView?.contentOffset ?? CGPoint.zero))
        }
        
        return _contentOffsetSubject!
    }

    /// Initializes `RxScrollViewDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.scrollView = (parentObject as! UIScrollView)
        super.init(parentObject: parentObject)
    }
    
    // MARK: delegate methods

    /// For more information take a look at `DelegateProxyType`.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let contentOffset = _contentOffsetSubject {
            contentOffset.on(.next(scrollView.contentOffset))
        }
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: delegate proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let scrollView = (object as! UIScrollView)
        
        return castOrFatalError(scrollView.createRxDelegateProxy())
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let scrollView: UIScrollView = castOrFatalError(object)
        scrollView.delegate = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let scrollView: UIScrollView = castOrFatalError(object)
        return scrollView.delegate
    }
    
    deinit {
        if let contentOffset = _contentOffsetSubject {
            contentOffset.on(.completed)
        }
    }
}

#endif
