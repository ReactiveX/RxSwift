//
//  WKWebView+Rx.swift
//  RxCocoa
//
//  Created by Andrew Breckenridge on 8/30/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

    import UIKit
    import WebKit
    import RxSwift

    extension Reactive where Base: WKWebView {

        /// Reactive wrapper for `delegate`.
        /// For more information take a look at `DelegateProxyType` protocol documentation.
        public var delegate: DelegateProxy<WKWebView, WKNavigationDelegate> {
            return RxWebViewDelegateProxy.proxy(for: base)
        }

        /// Reactive wrapper for `delegate` message.
        public var didStartLoad: Observable<Void> {
            return delegate
                .methodInvoked(#selector(WKNavigationDelegate.webView(_:didStartProvisionalNavigation:)))
                .map { _ in }
        }

        /// Reactive wrapper for `delegate` message.
        public var didFinishLoad: Observable<Void> {
            return delegate
                .methodInvoked(#selector(WKNavigationDelegate.webView(_:didFinish:)))
                .map { _ in }
        }
        
        /// Reactive wrapper for `delegate` message.
        public var didFailLoad: Observable<Error> {
            return delegate
                .methodInvoked(#selector(WKNavigationDelegate.webView(_:didFail:withError:)))
                .map { a in
                    return try castOrThrow(Error.self, a[1])
                }
        }
    }

#endif
