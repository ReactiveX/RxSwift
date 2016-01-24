//
//  WKWebView+Rx.swift
//  Rx
//
//  Created by Daichi Ichihara on 1/25/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//
#if os(iOS)
import Foundation
import WebKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension WKWebView {
    /**
     Reactive wrapper for `canGoBack` property.
    */
    public var rx_canGoBack: Observable<Bool> {
        return self.rx_observe(Bool.self, "canGoBack")
            .map { $0 ?? false }
    }

    /**
     Reactive wrapper for `canGoForward` property.
    */
    public var rx_canGoForward: Observable<Bool> {
        return self.rx_observe(Bool.self, "canGoForward")
            .map { $0 ?? false }
    }

    /**
     Reactive wrapper for `loading` property.
    */
    public var rx_loading: Observable<Bool> {
        return self.rx_observe(Bool.self, "loading")
            .map { $0 ?? false }
    }

    /**
     Reactive wrapper for `estimatedProgress` property.
    */
    public var rx_estimatedProgress: Observable<Double> {
        return self.rx_observe(Double.self, "estimatedProgress")
            .map { $0 ?? 0.0 }
    }

    /**
     Reactive wrapper for `title` property.
    */
    public var rx_title: Observable<String?> {
        return self.rx_observe(String.self, "title")
    }

    /**
     Reactive wrapper for `URL` property.
    */
    public var rx_URL: Observable<NSURL?> {
        return self.rx_observe(NSURL.self, "URL")
    }
}
#endif
