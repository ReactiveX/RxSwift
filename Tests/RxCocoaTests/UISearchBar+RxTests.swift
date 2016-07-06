//
//  UISearchBar+RxTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UISearchBarTests : RxTest {
    func testText_completesOnDealloc() {
        let createView: () -> UISearchBar = { UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: UISearchBar) in view.rx_text }
    }

    func testText_changeEventWorks() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        var latestText: String! = nil

        // search bar should dispose this itself
        _ = searchBar.rx_text.subscribeNext { text in
            latestText = text
        }

        XCTAssertEqual(latestText, "")

        searchBar.text = "newValue"
        searchBar.delegate!.searchBar!(searchBar, textDidChange: "newValue")

        XCTAssertEqual(latestText, "newValue")
    }

    func testText_binding() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertNotEqual(searchBar.text, "value")
        _ = Observable.just("value").bindTo(searchBar.rx_text)
        XCTAssertEqual(searchBar.text, "value")
    }

    func testSelectedScopeButtonIndex_completesOnDealloc() {
        let createView: () -> UISearchBar = { UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, 1) { (view: UISearchBar) in view.rx_selectedScopeButtonIndex }
    }
    
    func testSelectedScopeButtonIndex_changeEventWorks() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        searchBar.scopeButtonTitles = [ "One", "Two", "Three" ]
        
        var latestSelectedScopeIndex: Int = -1
        
        _ = searchBar.rx_selectedScopeButtonIndex.subscribeNext { index in
            latestSelectedScopeIndex = index
        }
        
        XCTAssertEqual(latestSelectedScopeIndex, 0)
        
        searchBar.selectedScopeButtonIndex = 1
        searchBar.delegate!.searchBar!(searchBar, selectedScopeButtonIndexDidChange: 1)
        
        XCTAssertEqual(latestSelectedScopeIndex, 1)
    }
    
    func testSelectedScopeButtonIndex_binding() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        searchBar.scopeButtonTitles = [ "One", "Two", "Three" ]
        
        XCTAssertNotEqual(searchBar.selectedScopeButtonIndex, 1)
        _ = Observable.just(1).bindTo(searchBar.rx_selectedScopeButtonIndex)
        XCTAssertEqual(searchBar.selectedScopeButtonIndex, 1)
    }
    
#if os(iOS)
    func testCancelButtonClicked() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        var tapped = false
        
        let _ = searchBar.rx_cancelButtonClicked.subscribeNext { _ in
            tapped = true
        }
        
        XCTAssertFalse(tapped)
        searchBar.delegate!.searchBarCancelButtonClicked!(searchBar)
        XCTAssertTrue(tapped)
    }
    
    func testCancelButtonClicked_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISearchBar = { UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx_cancelButtonClicked }
    }
#endif
    
    func testSearchButtonClicked() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        var tapped = false
        
        let _ = searchBar.rx_searchButtonClicked.subscribeNext { _ in
            tapped = true
        }
        
        XCTAssertFalse(tapped)
        searchBar.delegate!.searchBarSearchButtonClicked!(searchBar)
        XCTAssertTrue(tapped)
    }
    
    func testSearchButtonClicked_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISearchBar = { UISearchBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx_searchButtonClicked }
    }
}
