//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIScrollView {
    
    // factory
    
    func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxScrollViewDelegateProxy(parentObject: self)
    }
    
    // proxy 
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxScrollViewDelegateProxy
    }
    
    // properties
    
    public var rx_contentOffset: Observable<CGPoint> {
        let proxy = proxyForObject(self) as RxScrollViewDelegateProxy
        
        return proxy.contentOffsetSubject
    }
    
    // delegate

    // For more detailed explanations, take a look at `DelegateProxyType.swift`
    public func rx_setDelegate(delegate: UIScrollViewDelegate)
        -> Disposable {
        let proxy: RxScrollViewDelegateProxy = proxyForObject(self)
        return installDelegate(proxy, delegate, false, onProxyForObject: self)
    }
}