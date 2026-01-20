//
//  RxScrollViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

extension UIScrollView: HasDelegate {
    public typealias Delegate = UIScrollViewDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxScrollViewDelegateProxy:
    DelegateProxy<UIScrollView, UIScrollViewDelegate>,
    DelegateProxyType
{
    /// Typed parent object.
    public private(set) weak var scrollView: UIScrollView?

    /// - parameter scrollView: Parent object for delegate proxy.
    public init(scrollView: ParentObject) {
        self.scrollView = scrollView
        super.init(parentObject: scrollView, delegateProxy: RxScrollViewDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        register { RxScrollViewDelegateProxy(scrollView: $0) }
        register { RxTableViewDelegateProxy(tableView: $0) }
        register { RxCollectionViewDelegateProxy(collectionView: $0) }
        register { RxTextViewDelegateProxy(textView: $0) }
    }

    private var _contentOffsetBehaviorSubject: BehaviorSubject<CGPoint>?
    private var _contentOffsetPublishSubject: PublishSubject<Void>?

    /// Optimized version used for observing content offset changes.
    var contentOffsetBehaviorSubject: BehaviorSubject<CGPoint> {
        if let subject = _contentOffsetBehaviorSubject {
            return subject
        }

        let subject = BehaviorSubject<CGPoint>(value: scrollView?.contentOffset ?? CGPoint.zero)
        _contentOffsetBehaviorSubject = subject

        return subject
    }

    /// Optimized version used for observing content offset changes.
    var contentOffsetPublishSubject: PublishSubject<Void> {
        if let subject = _contentOffsetPublishSubject {
            return subject
        }

        let subject = PublishSubject<Void>()
        _contentOffsetPublishSubject = subject

        return subject
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

extension RxScrollViewDelegateProxy: UIScrollViewDelegate {
    /// For more information take a look at `DelegateProxyType`.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let subject = _contentOffsetBehaviorSubject {
            subject.on(.next(scrollView.contentOffset))
        }
        if let subject = _contentOffsetPublishSubject {
            subject.on(.next(()))
        }
        _forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
}

#endif
