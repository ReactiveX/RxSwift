//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

public extension Reactive where Base: UIScrollView {
    typealias EndZoomEvent = (view: UIView?, scale: CGFloat)
    typealias WillEndDraggingEvent = (velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        RxScrollViewDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `contentOffset`.
    var contentOffset: ControlProperty<CGPoint> {
        let proxy = RxScrollViewDelegateProxy.proxy(for: base)

        let bindingObserver = Binder(base) { scrollView, contentOffset in
            scrollView.contentOffset = contentOffset
        }

        return ControlProperty(values: proxy.contentOffsetBehaviorSubject, valueSink: bindingObserver)
    }

    /// Reactive wrapper for delegate method `scrollViewDidScroll`
    var didScroll: ControlEvent<Void> {
        let source = RxScrollViewDelegateProxy.proxy(for: base).contentOffsetPublishSubject
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillBeginDecelerating`
    var willBeginDecelerating: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidEndDecelerating`
    var didEndDecelerating: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillBeginDragging`
    var willBeginDragging: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)`
    var willEndDragging: ControlEvent<WillEndDraggingEvent> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)))
            .map { value -> WillEndDraggingEvent in
                let velocity = try castOrThrow(CGPoint.self, value[1])
                let targetContentOffsetValue = try castOrThrow(NSValue.self, value[2])

                guard let rawPointer = targetContentOffsetValue.pointerValue else { throw RxCocoaError.unknown }
                let typedPointer = rawPointer.bindMemory(to: CGPoint.self, capacity: MemoryLayout<CGPoint>.size)

                return (velocity, typedPointer)
            }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidEndDragging(_:willDecelerate:)`
    var didEndDragging: ControlEvent<Bool> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))).map { value -> Bool in
            return try castOrThrow(Bool.self, value[1])
        }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidZoom`
    var didZoom: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidZoom)).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidScrollToTop`
    var didScrollToTop: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidEndScrollingAnimation`
    var didEndScrollingAnimation: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillBeginZooming(_:with:)`
    var willBeginZooming: ControlEvent<UIView?> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:))).map { value -> UIView? in
            return try castOptionalOrThrow(UIView.self, value[1] as AnyObject)
        }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidEndZooming(_:with:atScale:)`
    var didEndZooming: ControlEvent<EndZoomEvent> {
        let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:))).map { value -> EndZoomEvent in
            return try (castOptionalOrThrow(UIView.self, value[1] as AnyObject), castOrThrow(CGFloat.self, value[2]))
        }
        return ControlEvent(events: source)
    }

    /// Installs delegate as forwarding delegate on `delegate`.
    /// Delegate won't be retained.
    ///
    /// It enables using normal delegate mechanism with reactive delegate mechanism.
    ///
    /// - parameter delegate: Delegate object.
    /// - returns: Disposable object that can be used to unbind the delegate.
    func setDelegate(_ delegate: UIScrollViewDelegate)
        -> Disposable
    {
        RxScrollViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
}

#endif
