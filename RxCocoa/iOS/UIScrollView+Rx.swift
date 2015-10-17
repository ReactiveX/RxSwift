//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
    func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxScrollViewDelegateProxy(parentObject: self)
    }
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxScrollViewDelegateProxy
    }
    
    /**
    Reactive wrapper for `contentOffset`.
    */
    public var rx_contentOffset: ControlProperty<CGPoint> {
        let proxy = proxyForObject(self) as RxScrollViewDelegateProxy
        
        return ControlProperty(source: proxy.contentOffsetSubject, observer: AnyObserver { [weak self] event in
            switch event {
            case .Next(let value):
                self?.contentOffset = value
            case .Error(let error):
                bindingErrorToInterface(error)
            case .Completed:
                break
            }
        })
    }
    
    /**
    Installs delegate as forwarding delegate on `rx_delegate`.
    
    It enables using normal delegate mechanism with reactive delegate mechanism.
    
    - parameter delegate: Delegate object.
    - returns: Disposable object that can be used to unbind the delegate.
    */
    public func rx_setDelegate(delegate: UIScrollViewDelegate)
        -> Disposable {
        let proxy: RxScrollViewDelegateProxy = proxyForObject(self)
        return installDelegate(proxy, delegate: delegate, retainDelegate: false, onProxyForObject: self)
    }
}

#endif
