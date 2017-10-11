//
//  NSPopUpButton+RxTests.swift
//  RxSwift-iOS
//
//  Created by Florent Pillet on 05/09/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import AppKit
import XCTest

final class NSPopUpButtonTests: RxTest {
	fileprivate func createPopup() -> NSPopUpButton {
		let popUp = NSPopUpButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		popUp.addItems(withTitles: ["a","b","c"])
		popUp.selectItem(at: 1)
		return popUp
	}
}

extension NSPopUpButtonTests {
	func testPopUp_selectedItemCompletesOnDealloc() {
		ensurePropertyDeallocated(createPopup, -1) { (popUp: NSPopUpButton) in popUp.rx.selectedItemIndex }
	}
	
	func testPopUp_selectedItemIndex() {
		var completed = false
		var value: Int?
		
		autoreleasepool {
			let popUp = createPopup()

			_ = popUp.rx.selectedItemIndex.subscribe(
				onNext: { index in value = index },
				onCompleted: { completed = true })
		}
		
		XCTAssertNotNil(value)
		XCTAssertEqual(value, 1)
		XCTAssertTrue(completed)
	}

	func testPopUp_selectedItemTitle() {
		var completed = false
		var value: String?
		
		autoreleasepool {
			let popUp = createPopup()
			
			_ = popUp.rx.selectedItemTitle.subscribe(
				onNext: { title in value = title },
				onCompleted: { completed = true })
		}
		
		XCTAssertNotNil(value)
		XCTAssertEqual(value, "b")
		XCTAssertTrue(completed)
	}

	func testPopUp_selectedItem() {
		var completed = false
		var value: NSMenuItem?
		
		autoreleasepool {
			let popUp = createPopup()
			
			_ = popUp.rx.selectedItem.subscribe(
				onNext: { title in value = title },
				onCompleted: { completed = true })
		}
		
		XCTAssertNotNil(value)
		XCTAssertEqual(value?.title, "b")
		XCTAssertTrue(completed)
	}
	
	func testPopUp_setItems() {
		let popUp = createPopup()
		popUp.rx.menuItems().onNext(["Hello","World"])
		
		XCTAssertEqual(popUp.itemArray.count, 2)
		XCTAssertEqual(popUp.itemArray[0].title, "Hello")
		XCTAssertEqual(popUp.itemArray[1].title, "World")
	}
	
	func testPopUp_setItemsAndTags() {
		let popUp = createPopup()
		popUp.rx.menuItemsWithTags().onNext([("Hello",1), ("World",2)])
		
		XCTAssertEqual(popUp.itemArray.count, 2)
		XCTAssertEqual(popUp.itemArray[0].title, "Hello")
		XCTAssertEqual(popUp.itemArray[0].tag, 1)
		XCTAssertEqual(popUp.itemArray[1].title, "World")
		XCTAssertEqual(popUp.itemArray[1].tag, 2)
	}
	
	func testPopUp_selectedItemTag() {
		var completed = false
		var value: Int?
		
		autoreleasepool {
			let popUp = createPopup()
			popUp.rx.menuItemsWithTags().onNext([("Hello",1), ("World",2)])
			popUp.selectItem(at: 1)

			_ = popUp.rx.selectedItemTag.subscribe(
				onNext: { tag in value = tag },
				onCompleted: { completed = true })
		}

		XCTAssertNotNil(value)
		XCTAssertEqual(value, 2)
		XCTAssertTrue(completed)
	}
}
