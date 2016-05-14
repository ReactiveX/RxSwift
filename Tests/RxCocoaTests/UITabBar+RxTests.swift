//
//  UITabBar+RxTests.swift
//  Rx
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UITabBar_RxTests: RxTest {
    let createSubject: () -> UITabBar = { UITabBar(frame: CGRectMake(0, 0, 1, 1)) }
}

/**
 iOS only
 */
#if os(iOS)
extension UITabBar_RxTests {

    func testBarStyle() {
        let subject = createSubject()
        XCTAssertEqual(subject.barStyle, UIBarStyle.Default)

        Observable.just(UIBarStyle.Black).subscribe(subject.rx_barStyle).dispose()

        XCTAssertEqual(subject.barStyle, UIBarStyle.Black)
    }

    func testItemPositioning() {
        let subject = createSubject()
        XCTAssertEqual(subject.itemPositioning, UITabBarItemPositioning.Automatic)

        Observable.just(.Fill).subscribe(subject.rx_itemPositioning).dispose()

        XCTAssertEqual(subject.itemPositioning, UITabBarItemPositioning.Fill)
    }

}
#endif

/**
 iOS and tvOS
 */
extension UITabBar_RxTests {

    func testItems() {
        let subject = createSubject()
        XCTAssertNil(subject.items)

        let items = [UITabBarItem()]
        Observable.just(items).subscribe(subject.rx_items).dispose()

        let currentItems = subject.items
        XCTAssertNotNil(currentItems)
        if let currentItems = currentItems {
            XCTAssertEqual(currentItems, items)
        }
    }

    func testItemsAnimated() {
        let subject = createSubject()
        XCTAssertNil(subject.items)

        let items = [UITabBarItem()]
        Observable.just(items).subscribe(subject.rx_items(true)).dispose()

        let currentItems = subject.items
        XCTAssertNotNil(currentItems)
        if let currentItems = currentItems {
            XCTAssertEqual(currentItems, items)
        }
    }

    func testTranslucent() {
        let subject = createSubject()
        XCTAssertTrue(subject.translucent)

        Observable.just(false).subscribe(subject.rx_translucent).dispose()

        XCTAssertFalse(subject.translucent)
    }

    func testBarTintColor() {
        let subject = createSubject()
        XCTAssertEqual(subject.barTintColor, nil)

        Observable.just(UIColor.purpleColor()).subscribe(subject.rx_barTintColor).dispose()

        XCTAssertEqual(subject.barTintColor, UIColor.purpleColor())
    }

    func testItemSpacing() {
        let subject = createSubject()
        XCTAssertEqualWithAccuracy(subject.itemSpacing, 0, accuracy: 0.00001)

        Observable.just(77).subscribe(subject.rx_itemSpacing).dispose()

        XCTAssertEqualWithAccuracy(subject.itemSpacing, 77, accuracy: 0.00001)
    }

    func testItemWidth() {
        let subject = createSubject()
        XCTAssertEqualWithAccuracy(subject.itemWidth, 0, accuracy: 0.00001)

        Observable.just(42).subscribe(subject.rx_itemWidth).dispose()

        XCTAssertEqualWithAccuracy(subject.itemWidth, 42, accuracy: 0.00001)
    }

    func testTintColor() {
        let subject = createSubject()
        // The default color comes from the view hierarchy, so set the parent's tintColor
        let parentView = UIView(frame: CGRectMake(0, 0, 1, 1))
        parentView.tintColor = UIColor.redColor()
        parentView.addSubview(subject)
        XCTAssertEqual(subject.tintColor, UIColor.redColor())

        Observable.just(UIColor.purpleColor()).subscribe(subject.rx_tintColor).dispose()

        XCTAssertEqual(subject.tintColor, UIColor.purpleColor())
    }

    func testBackgroundImage() {
        let subject = createSubject()
        XCTAssertEqual(subject.backgroundImage, nil)

        let image = UIImage()
        Observable.just(image).subscribe(subject.rx_backgroundImage).dispose()

        XCTAssertEqual(subject.backgroundImage, image)
    }

    func testShadowImage() {
        let subject = createSubject()
        XCTAssertEqual(subject.shadowImage, nil)

        let image = UIImage()
        Observable.just(image).subscribe(subject.rx_shadowImage).dispose()

        XCTAssertEqual(subject.shadowImage, image)
    }

    func testSelectionIndicatorImage() {
        let subject = createSubject()
        XCTAssertEqual(subject.selectionIndicatorImage, nil)

        let image = UIImage()
        Observable.just(image).subscribe(subject.rx_selectionIndicatorImage).dispose()

        XCTAssertEqual(subject.selectionIndicatorImage, image)
    }

}

#endif
