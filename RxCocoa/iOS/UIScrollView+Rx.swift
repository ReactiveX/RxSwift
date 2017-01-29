//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

    #if !RX_NO_MODULE
        import RxSwift
    #endif

    import UIKit

    extension UIScrollView {
        
        /// Factory method that enables subclasses to implement their own `delegate`.
        ///
        /// - returns: Instance of delegate proxy that wraps `delegate`.
        public func createRxDelegateProxy() -> RxScrollViewDelegateProxy {
            return RxScrollViewDelegateProxy(parentObject: self)
        }
        
    }

    extension Reactive where Base: UIScrollView {

        /// Reactive wrapper for `delegate`.
        ///
        /// For more information take a look at `DelegateProxyType` protocol documentation.
        public var delegate: DelegateProxy {
            return RxScrollViewDelegateProxy.proxyForObject(base)
        }
        
        /// Reactive wrapper for `contentOffset`.
        public var contentOffset: ControlProperty<CGPoint> {
            let proxy = RxScrollViewDelegateProxy.proxyForObject(base)

            let bindingObserver = UIBindingObserver(UIElement: self.base) { scrollView, contentOffset in
                scrollView.contentOffset = contentOffset
            }

            return ControlProperty(values: proxy.contentOffsetBehaviorSubject, valueSink: bindingObserver)
        }

        /// Bindable sink for `scrollEnabled` property.
        public var isScrollEnabled: UIBindingObserver<Base, Bool> {
            return UIBindingObserver(UIElement: self.base) { scrollView, scrollEnabled in
                scrollView.isScrollEnabled = scrollEnabled
            }
        }

        /// Reactive wrapper for delegate method `scrollViewDidScroll`
        public var didScroll: ControlEvent<Void> {
            let source = RxScrollViewDelegateProxy.proxyForObject(base).contentOffsetPublishSubject
            return ControlEvent(events: source)
        }
    	
    	/// Reactive wrapper for delegate method `scrollViewDidEndDecelerating`
    	public var didEndDecelerating: ControlEvent<Void> {
    		let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:))).map { _ in }
    		return ControlEvent(events: source)
    	}
    	
    	/// Reactive wrapper for delegate method `scrollViewDidEndDragging(_:willDecelerate:)`
    	public var didEndDragging: ControlEvent<Bool> {
    		let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))).map { value -> Bool in
    			return try castOrThrow(Bool.self, value[1])
    		}
    		return ControlEvent(events: source)
    	}

        /// Reactive wrapper for delegate method `scrollViewDidZoom`
        public var didZoom: ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidZoom)).map { _ in }
            return ControlEvent(events: source)
        }


        /// Reactive wrapper for delegate method `scrollViewDidScrollToTop`
        public var didScrollToTop: ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:))).map { _ in }
            return ControlEvent(events: source)
        }
        
        /// Reactive wrapper for delegate method `scrollViewDidEndScrollingAnimation`
        public var didEndScrollingAnimation: ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:))).map { _ in }
            return ControlEvent(events: source)
        }

        /// Installs delegate as forwarding delegate on `delegate`.
        /// Delegate won't be retained.
        ///
        /// It enables using normal delegate mechanism with reactive delegate mechanism.
        ///
        /// - parameter delegate: Delegate object.
        /// - returns: Disposable object that can be used to unbind the delegate.
        public func setDelegate(_ delegate: UIScrollViewDelegate)
            -> Disposable {
            return RxScrollViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
        }
    }

#endif
