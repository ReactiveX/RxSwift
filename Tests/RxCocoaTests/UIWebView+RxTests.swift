//
//  UIWebView+RxTests.swift
//  Rx
//
//  Created by Andrew Breckenridge on 8/30/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
    
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxBlocking
import XCTest

class UIWebViewTests: RxTest {}

fileprivate let testHTMLString = "<html><head></head><body><h1>🔥</h1></body></html>"
    
extension UIWebViewTests {
        
    func testDidStartLoad() {
        let webView = UIWebView()
        let expect = expectation(description: "webView did start loading")

        let subscription = webView.rx.didStartLoad.subscribe(onNext: {
            expect.fulfill()
        })

        webView.loadHTMLString(testHTMLString, baseURL: nil)

        waitForExpectations(timeout: 1, handler: { error in
            XCTAssertNil(error)
            subscription.dispose()
        })
    }
    
    func testDidFinishLoad() {
        let webView = UIWebView()
        let expect = expectation(description: "webView did finish loading")

        let subscription = webView.rx.didFinishLoad.subscribe(onNext: {
            expect.fulfill()
        })

        webView.loadHTMLString("<html></html>", baseURL: nil)

        waitForExpectations(timeout: 1, handler: { error in
            XCTAssertNil(error)
            subscription.dispose()
        })
    }

    func testDidFailLoad() {
        let webView = UIWebView()
        let expect = expectation(description: "webView did fail load")

        let subscription = webView.rx.didFailLoad.subscribe { _ in
            expect.fulfill()
        }

        webView.delegate!.webView!(webView, didFailLoadWithError: NSError(domain: "", code: 0, userInfo: .none))

        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
            subscription.dispose()
        })
    }
    
}

#endif
