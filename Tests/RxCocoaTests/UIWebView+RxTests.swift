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
import XCTest

class UIWebViewTests: RxTest {}

/// delegate methods

extension UIWebViewTests {
        
    func testDidStartLoad() {
        var delegateFiredDidStartLoad = false
        
        let webView = UIWebView()
        webView.loadRequest(URLRequest(url: URL(string: "")!))
        
        let subscription = webView.rx.didStartLoad.subscribe(onNext: {
            delegateFiredDidStartLoad = true
        })
        
        XCTAssertTrue(delegateFiredDidStartLoad)
        subscription.dispose()
    }
    
    func testDidFinishLoad() {
        var delegateFiredDidFinishLoad = false
        
        let webView = UIWebView()
        webView.loadRequest(URLRequest(url: URL(string: "")!))
        
        let subscription = webView.rx.didFinishLoad.subscribe(onNext: {
            delegateFiredDidFinishLoad = true
        })

        XCTAssertTrue(delegateFiredDidFinishLoad)
        subscription.dispose()
    }
    
    func testDidFailLoad() {
        var delegateFiredDidFailLoad = false
        
        let webView = UIWebView()
        webView.loadRequest(URLRequest(url: URL(string: "")!))
        
        let subscription = webView.rx.didFinishLoad.subscribe(onNext: {
            delegateFiredDidFailLoad = true
        })
        
        XCTAssertTrue(delegateFiredDidFailLoad)
        subscription.dispose()
    }
    
}

#endif
