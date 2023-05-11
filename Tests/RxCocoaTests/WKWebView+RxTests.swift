//
//  WKWebView+RxTests.swift
//  Tests
//
//  Created by Giuseppe Lanza on 14/02/2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(macOS)

import WebKit
import RxCocoa
import RxSwift
import RxBlocking
import XCTest

@available(iOS 10.0, macOSApplicationExtension 10.10, *)
final class WKWebViewTests: RxTest {
    
    override func setUp() {
        super.setUp()
        SafeWKNavigation.toggleSafeDealloc()
    }
    
    override func tearDown() {
        SafeWKNavigation.toggleSafeDealloc()
        super.tearDown()
    }
    
    func testDidCommit() {
        let expectedNavigation = SafeWKNavigation()
        let webView = WKWebView(frame: .zero)
        var navigation: WKNavigation?
        
        let subscription = webView.rx.didCommit.subscribe(onNext: { nav in
            navigation = nav
        })

        webView.navigationDelegate!.webView?(webView, didCommit: expectedNavigation)

        XCTAssertEqual(expectedNavigation, navigation)
        subscription.dispose()
    }
    
    func testDidStartLoad() {
        let expectedNavigation = SafeWKNavigation()
        let webView = WKWebView(frame: .zero)
        var navigation: WKNavigation?
        
        let subscription = webView.rx.didStartLoad.subscribe(onNext: { nav in
            navigation = nav
        })

        webView.navigationDelegate!.webView?(webView, didStartProvisionalNavigation: expectedNavigation)

        XCTAssertEqual(expectedNavigation, navigation)
        subscription.dispose()
    }
    
    func testDidFinishLoad() {
        let expectedNavigation = SafeWKNavigation()
        let webView = WKWebView(frame: .zero)
        var navigation: WKNavigation?
        
        let subscription = webView.rx.didFinishLoad.subscribe(onNext: { nav in
            navigation = nav
        })

        webView.navigationDelegate!.webView?(webView, didFinish: expectedNavigation)

        XCTAssertEqual(expectedNavigation, navigation)
        subscription.dispose()
    }
    
    func testDidFail() {
        let expectedNavigation = SafeWKNavigation()
        let expectedError = MockError.error("Something horrible just happened")
        let webView = WKWebView(frame: .zero)
        var navigation: WKNavigation?
        var error: Error?
        
        let subscription = webView.rx.didFailLoad.subscribe(onNext: { nav, err in
            navigation = nav
            error = err
        })

        webView.navigationDelegate!.webView?(webView, didFail: expectedNavigation, withError: expectedError)

        XCTAssertEqual(expectedNavigation, navigation)
        XCTAssertEqual(expectedError, error as? MockError)
        subscription.dispose()
    }
}

// MARK: - Test Helpers
// Any WKNavigation object manually created on dealloc crashes the program.
// This class overrides the deinit method of the WKNavition to avoid crashes.
@available(iOS 10.0, macOSApplicationExtension 10.10, *)
private class SafeWKNavigation: WKNavigation {
    static func toggleSafeDealloc() {
        guard let current_original = class_getInstanceMethod(SafeWKNavigation.self, NSSelectorFromString("dealloc")),
              let current_swizzled = class_getInstanceMethod(SafeWKNavigation.self, #selector(nonCrashingDealloc))
              else { return }
        method_exchangeImplementations(current_original, current_swizzled)
    }
    
    @objc func nonCrashingDealloc() { }
}

private enum MockError: Error, Equatable {
    case error(String)
}

#endif
