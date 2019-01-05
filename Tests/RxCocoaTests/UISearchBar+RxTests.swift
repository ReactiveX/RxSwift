//
//  UISearchBar+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 3/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UISearchBarTests : RxTest {
}

extension UISearchBarTests {

    func testText_completesOnDealloc() {
        let createView: () -> UISearchBar = { self.newSearchBar() }
        ensurePropertyDeallocated(createView, "a") { (view: UISearchBar) in view.rx.text.orEmpty }
    }

    func testValue_completesOnDealloc() {
        let createView: () -> UISearchBar = { self.newSearchBar() }
        ensurePropertyDeallocated(createView, "a") { (view: UISearchBar) in view.rx.value.orEmpty }
    }

    func testText_changeEventWorksForTextDidChange() {
        let searchBar = self.newSearchBar()

        var latestText: String! = nil

        // search bar should dispose this itself
        _ = searchBar.rx.text.subscribe(onNext: { text in
            latestText = text
        })

        XCTAssertEqual(latestText, "")

        searchBar.text = "newValue"
        searchBar.delegate!.searchBar!(searchBar, textDidChange: "doesntMatter")

        XCTAssertEqual(latestText, "newValue")
    }

    func testText_changeEventWorksForDidEndEditing() {
        let searchBar = self.newSearchBar()

        var latestText: String! = nil

        // search bar should dispose this itself
        _ = searchBar.rx.text.subscribe(onNext: { text in
            latestText = text
        })

        XCTAssertEqual(latestText, "")

        searchBar.text = "newValue"
        searchBar.delegate!.searchBarTextDidEndEditing!(searchBar)

        XCTAssertEqual(latestText, "newValue")
    }

    func testText_binding() {
        let searchBar = self.newSearchBar()

        XCTAssertNotEqual(searchBar.text, "value")
        _ = Observable.just("value").bind(to: searchBar.rx.text)
        XCTAssertEqual(searchBar.text, "value")
    }

    func testSelectedScopeButtonIndex_completesOnDealloc() {
        let createView: () -> UISearchBar = { self.newSearchBar() }
        ensurePropertyDeallocated(createView, 1) { (view: UISearchBar) in view.rx.selectedScopeButtonIndex }
    }
    
    func testSelectedScopeButtonIndex_changeEventWorks() {
        let searchBar = self.newSearchBar()
        searchBar.scopeButtonTitles = [ "One", "Two", "Three" ]
        
        var latestSelectedScopeIndex: Int = -1
        
        _ = searchBar.rx.selectedScopeButtonIndex.subscribe(onNext: { index in
            latestSelectedScopeIndex = index
        })
        
        XCTAssertEqual(latestSelectedScopeIndex, 0)
        
        searchBar.selectedScopeButtonIndex = 1
        searchBar.delegate!.searchBar!(searchBar, selectedScopeButtonIndexDidChange: 1)
        
        XCTAssertEqual(latestSelectedScopeIndex, 1)
    }
    
    func testSelectedScopeButtonIndex_binding() {
        let searchBar = self.newSearchBar()
        searchBar.scopeButtonTitles = [ "One", "Two", "Three" ]
        
        XCTAssertNotEqual(searchBar.selectedScopeButtonIndex, 1)
        _ = Observable.just(1).bind(to: searchBar.rx.selectedScopeButtonIndex)
        XCTAssertEqual(searchBar.selectedScopeButtonIndex, 1)
    }
    
#if os(iOS)
    func testCancelButtonClicked() {
        let searchBar = self.newSearchBar()
        
        var tapped = false
        
        _ = searchBar.rx.cancelButtonClicked.subscribe(onNext: { _ in
            tapped = true
        })
        
        XCTAssertFalse(tapped)
        searchBar.delegate!.searchBarCancelButtonClicked!(searchBar)
        XCTAssertTrue(tapped)
    }
    
    func testCancelButtonClicked_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISearchBar = { self.newSearchBar() }
        ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx.cancelButtonClicked }
    }
	
	func testBookmarkButtonClicked() {
		let searchBar = self.newSearchBar()
		
		var tapped = false
		
		_ = searchBar.rx.bookmarkButtonClicked.subscribe(onNext: { _ in
			tapped = true
		})
		
		XCTAssertFalse(tapped)
		searchBar.delegate!.searchBarBookmarkButtonClicked!(searchBar)
		XCTAssertTrue(tapped)
	}
	
	func testBookmarkButtonClicked_DelegateEventCompletesOnDealloc() {
		let createView: () -> UISearchBar = { self.newSearchBar() }
		ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx.bookmarkButtonClicked }
	}
	
	func testResultsListButtonClicked() {
		let searchBar = self.newSearchBar()
		
		var tapped = false
		
		_ = searchBar.rx.resultsListButtonClicked.subscribe(onNext: { _ in
			tapped = true
		})
		
		XCTAssertFalse(tapped)
		searchBar.delegate!.searchBarResultsListButtonClicked!(searchBar)
		XCTAssertTrue(tapped)
	}
	
	func testResultsListButtonClicked_DelegateEventCompletesOnDealloc() {
		let createView: () -> UISearchBar = { self.newSearchBar() }
		ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx.resultsListButtonClicked }
	}
	
#endif
	
    func testSearchButtonClicked() {
        let searchBar = self.newSearchBar()
        
        var tapped = false
        
        _ = searchBar.rx.searchButtonClicked.subscribe(onNext: { _ in
            tapped = true
        })
        
        XCTAssertFalse(tapped)
        searchBar.delegate!.searchBarSearchButtonClicked!(searchBar)
        XCTAssertTrue(tapped)
    }
    
    func testSearchButtonClicked_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISearchBar = { self.newSearchBar() }
        ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx.searchButtonClicked }
    }
	
	func testSearchBarTextDidBeginEditing(){
		let searchBar = self.newSearchBar()

		var tapped = false
		_ = searchBar.rx.textDidBeginEditing.subscribe(onNext: { _ in
			tapped = true
		})
		XCTAssertFalse(tapped)
		searchBar.delegate!.searchBarTextDidBeginEditing!(searchBar)
		XCTAssertTrue(tapped)
	}

	func testSearchBarTextDidBeginEditing_DelegateEventCompletesOnDealloc() {
		let createView: () -> UISearchBar = { self.newSearchBar() }
		ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx.textDidBeginEditing }
	}
	
	func testSearchBarTextDidEndEditing(){
		let searchBar = self.newSearchBar()
		
		var tapped = false
		_ = searchBar.rx.textDidEndEditing.subscribe(onNext: { _ in
			tapped = true
		})
		XCTAssertFalse(tapped)
		searchBar.delegate!.searchBarTextDidBeginEditing!(searchBar)
		XCTAssertFalse(tapped)
		searchBar.delegate!.searchBarTextDidEndEditing!(searchBar)
		XCTAssertTrue(tapped)
	}

	func testSearchBarTextDidEndEditing_DelegateEventCompletesOnDealloc() {
		let createView: () -> UISearchBar = { self.newSearchBar() }
		ensureEventDeallocated(createView) { (view: UISearchBar) in view.rx.textDidEndEditing }
	}
	
}

extension UISearchBarTests {
    func newSearchBar() -> UISearchBar {
        return autoreleasepool {
            let vc = UIViewController()
            let searchController = UISearchController(searchResultsController: vc)
            return searchController.searchBar
        }
    }
}
