//
//  RxWebViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Andrew Breckenridge on 9/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

open class RxWebViewDelegateProxy<P: UIWebView>
    : DelegateProxy<P, UIWebViewDelegate>
    , DelegateProxyType 
    , UIWebViewDelegate {

    public static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: RxWebViewDelegateProxy<UIWebView>.self)
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: UIWebViewDelegate?, toObject object: P) {
        object.delegate = delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegate(for object: P) -> UIWebViewDelegate? {
        return object.delegate
    }
}

#endif
