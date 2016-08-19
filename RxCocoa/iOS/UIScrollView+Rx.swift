//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIScrollView {
    
    /**
    Factory method that enables subclasses to implement their own `rx_delegate`.
    
    - returns: Instance of delegate proxy that wraps `delegate`.
    */
    public func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxScrollViewDelegateProxy(parentObject: self)
    }
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return RxScrollViewDelegateProxy.proxyForObject(self)
    }
    
    /**
    Reactive wrapper for `contentOffset`.
    */
    public var rx_contentOffset: ControlProperty<CGPoint> {
        let proxy = RxScrollViewDelegateProxy.proxyForObject(self)

        let bindingObserver = UIBindingObserver(UIElement: self) { scrollView, contentOffset in
            scrollView.contentOffset = contentOffset
        }

        return ControlProperty(values: proxy.contentOffsetSubject, valueSink: bindingObserver)
    }

    /**
    Bindable sink for `scrollEnabled` property.
    */
    public var rx_scrollEnabled: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { scrollView, scrollEnabled in
            scrollView.scrollEnabled = scrollEnabled
        }.asObserver()
    }

    /**
    Installs delegate as forwarding delegate on `rx_delegate`.
    Delegate won't be retained.
    
    It enables using normal delegate mechanism with reactive delegate mechanism.
    
    - parameter delegate: Delegate object.
    - returns: Disposable object that can be used to unbind the delegate.
    */
    public func rx_setDelegate(delegate: UIScrollViewDelegate)
        -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self)
    }
}

#endif
