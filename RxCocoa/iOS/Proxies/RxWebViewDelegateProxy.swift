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

extension UIWebView: HasDelegate {
    public typealias Delegate = UIWebViewDelegate
}

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
}

#endif
