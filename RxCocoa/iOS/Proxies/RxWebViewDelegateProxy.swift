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

    /// Typed parent object.
    public weak private(set) var webView: UIWebView?

    /// - parameter parentObject: Parent object for delegate proxy.
    public init(parentObject: ParentObject) {
        self.webView = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxWebViewDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxWebViewDelegateProxy(parentObject: $0) }
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: UIWebViewDelegate?, to object: UIWebView) {
        object.delegate = delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: UIWebView) -> UIWebViewDelegate? {
        return object.delegate
    }
}

#endif
