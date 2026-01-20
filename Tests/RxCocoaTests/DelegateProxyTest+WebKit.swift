//
//  DelegateProxyTest+WebKit.swift
//  Tests
//
//  Created by Giuseppe Lanza on 14/02/2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(macOS)

@testable import RxCocoa
@testable import RxSwift
import WebKit
import XCTest

@available(iOS 10.0, macOSApplicationExtension 10.10, *)
extension DelegateProxyTest {
    func test_WKNavigaionDelegateExtension() {
        performDelegateTest(WKNavigationWebViewSubclass(frame: CGRect.zero)) { ExtendWKNavigationDelegateProxy(webViewSubclass: $0) }
    }
}

@available(iOS 10.0, macOSApplicationExtension 10.10, *)
final class ExtendWKNavigationDelegateProxy:
    RxWKNavigationDelegateProxy,
    TestDelegateProtocol
{
    init(webViewSubclass: WKNavigationWebViewSubclass) {
        super.init(webView: webViewSubclass)
    }
}

@available(iOS 8.0, macOS 10.10, macOSApplicationExtension 10.10, *)
final class WKNavigationWebViewSubclass: WKWebView, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (navigationDelegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<WKWebView, WKNavigationDelegate> {
        rx.navigationDelegate
    }

    func setMineForwardDelegate(_ testDelegate: WKNavigationDelegate) -> Disposable {
        RxWKNavigationDelegateProxy.installForwardDelegate(
            testDelegate,
            retainDelegate: false,
            onProxyForObject: self,
        )
    }
}

// MARK: Mocks

@available(iOS 10.0, macOSApplicationExtension 10.10, *)
extension MockTestDelegateProtocol:
    WKNavigationDelegate
{}

#endif
