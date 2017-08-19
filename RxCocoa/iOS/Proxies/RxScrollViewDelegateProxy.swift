//
//  RxScrollViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

/// For more information take a look at `DelegateProxyType`.
open class RxScrollViewDelegateProxy<P: UIScrollView>
    : DelegateProxy<P, UIScrollViewDelegate>
    , DelegateProxyType 
    , UIScrollViewDelegate {
    
    public static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: RxScrollViewDelegateProxy<UIScrollView>.self) {
            RxTableViewDelegateProxy<UITableView>.register()
            RxCollectionViewDelegateProxy<UICollectionView>.register()
            RxTextViewDelegateProxy<UITextView>.register()
        }
    }

    fileprivate var _contentOffsetBehaviorSubject: BehaviorSubject<CGPoint>?
    fileprivate var _contentOffsetPublishSubject: PublishSubject<()>?

    /// Typed parent object.
    public weak fileprivate(set) var scrollView: UIScrollView?

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetBehaviorSubject: BehaviorSubject<CGPoint> {
        if let subject = _contentOffsetBehaviorSubject {
            return subject
        }

        let subject = BehaviorSubject<CGPoint>(value: self.scrollView?.contentOffset ?? CGPoint.zero)
        _contentOffsetBehaviorSubject = subject

        return subject
    }

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetPublishSubject: PublishSubject<()> {
        if let subject = _contentOffsetPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _contentOffsetPublishSubject = subject

        return subject
    }

    /// Initializes `RxScrollViewDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: ParentObject) {
        self.scrollView = parentObject
        super.init(parentObject: parentObject)
    }
    
    // MARK: delegate methods

    /// For more information take a look at `DelegateProxyType`.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let subject = _contentOffsetBehaviorSubject {
            subject.on(.next(scrollView.contentOffset))
        }
        if let subject = _contentOffsetPublishSubject {
            subject.on(.next(()))
        }
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: delegate proxy

    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: UIScrollViewDelegate?, toObject object: ParentObject) {
        object.delegate = delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegateFor(_ object: ParentObject) -> UIScrollViewDelegate? {
        return object.delegate
    }
    
    deinit {
        if let subject = _contentOffsetBehaviorSubject {
            subject.on(.completed)
        }

        if let subject = _contentOffsetPublishSubject {
            subject.on(.completed)
        }
    }
}

#endif
