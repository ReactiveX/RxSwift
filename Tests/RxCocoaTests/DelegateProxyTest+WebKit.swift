//
//  DelegateProxyTest+WebKit.swift
//  Tests
//
//  Created by Giuseppe Lanza on 14/02/2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(macOS)

import WebKit
@testable import RxCocoa
@testable import RxSwift
import XCTest

@available(iOS 10.0, OSXApplicationExtension 10.10, *)
extension DelegateProxyTest {
    func test_WKNavigaionDelegateExtension() {
        performDelegateTest(WKNavigationWebViewSubclass(frame: CGRect.zero)) { ExtendWKNavigationDelegateProxy(webViewSubclass: $0) }
    }
}

@available(iOS 10.0, OSXApplicationExtension 10.10, *)
final class ExtendWKNavigationDelegateProxy
    : RxWKNavigationDelegateProxy
    , TestDelegateProtocol {
    init(webViewSubclass: WKNavigationWebViewSubclass) {
        super.init(webView: webViewSubclass)
    }
}

@available(iOS 8.0, OSX 10.10, OSXApplicationExtension 10.10, *)
final class WKNavigationWebViewSubclass: WKWebView, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (navigationDelegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<WKWebView, WKNavigationDelegate> {
        return self.rx.navigationDelegate
    }

    func setMineForwardDelegate(_ testDelegate: WKNavigationDelegate) -> Disposable {
        return RxWKNavigationDelegateProxy.installForwardDelegate(testDelegate,
                                                             retainDelegate: false,
                                                             onProxyForObject: self)
    }
}

// MARK: Mocks

@available(iOS 10.0, OSXApplicationExtension 10.10, *)
extension MockTestDelegateProtocol
    : WKNavigationDelegate
{
}

#endif
