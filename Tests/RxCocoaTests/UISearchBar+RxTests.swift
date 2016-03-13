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
        let createView: () -> UISearchBar = { UISearchBar(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: UISearchBar) in view.rx_text }
    }

    func testText_changeEventWorks() {
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, 1, 1))

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
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, 1, 1))

        XCTAssertNotEqual(searchBar.text, "value")
        _ = Observable.just("value").bindTo(searchBar.rx_text)
        XCTAssertEqual(searchBar.text, "value")
    }
}