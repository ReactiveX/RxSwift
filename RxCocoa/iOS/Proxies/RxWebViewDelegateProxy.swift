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

open class RxWebViewDelegateProxy
    : DelegateProxy<UIWebView, UIWebViewDelegate>
    , DelegateProxyType 
    , UIWebViewDelegate {

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxWebViewDelegateProxy(parentObject: $0) }
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: UIWebViewDelegate?, toObject object: UIWebView) {
        object.delegate = delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegate(for object: UIWebView) -> UIWebViewDelegate? {
        return object.delegate
    }
}

#endif
