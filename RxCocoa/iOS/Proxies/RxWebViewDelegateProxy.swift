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

public class RxWebViewDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , UIWebViewDelegate {
    
    public static var factory = DelegateProxyFactory { (parentObject: UIWebView) in
        RxWebViewDelegateProxy(parentObject: parentObject)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let webView: UIWebView = castOrFatalError(object)
        webView.delegate = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let webView: UIWebView = castOrFatalError(object)
        return webView.delegate
    }


}

#endif
