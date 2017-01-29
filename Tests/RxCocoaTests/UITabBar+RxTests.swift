//
//  UITabBar+RxTests.swift
//  Tests
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UITabBarTests: RxTest {
    let createSubject: () -> UITabBar = { UITabBar(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
}

/**
 iOS only
 */
#if os(iOS)
extension UITabBarTests {

    func testWillBeginCustomizing() {
        let subject = createSubject()

        let items = [UITabBarItem()]
        var returnedItems: [UITabBarItem]!

        _ = subject.rx.willBeginCustomizing
            .subscribe(onNext: { i in
                returnedItems = i
            })
        subject.delegate!.tabBar!(subject, willBeginCustomizing: items)

        XCTAssertEqual(returnedItems, items)
    }

    func testDidBeginCustomizing() {
        let subject = createSubject()

        let items = [UITabBarItem()]
        var returnedItems: [UITabBarItem]!

        _ = subject.rx.didBeginCustomizing
            .subscribe(onNext: { i in
                returnedItems = i
            })

        subject.delegate!.tabBar!(subject, didBeginCustomizing: items)

        XCTAssertEqual(returnedItems, items)
    }

    func testWillEndCustomizing() {
        let subject = createSubject()

        let items = [UITabBarItem()]
        var returnedItems: [UITabBarItem]!
        var changed: Bool!

        _ = subject.rx.willEndCustomizing
            .subscribe(onNext: { (i, c) in
                returnedItems = i
                changed = c
            })
        subject.delegate!.tabBar!(subject, willEndCustomizing: items, changed: true)

        XCTAssertEqual(returnedItems, items)
        XCTAssertEqual(changed, true)
    }

    func testDidEndCustomizing() {
        let subject = createSubject()

        let items = [UITabBarItem()]
        var returnedItems: [UITabBarItem]!
        var changed: Bool!

        _ = subject.rx.didEndCustomizing
            .subscribe(onNext: { (i, c) in
                returnedItems = i
                changed = c
            })

        subject.delegate!.tabBar!(subject, didEndCustomizing: items, changed: true)

        XCTAssertEqual(returnedItems, items)
        XCTAssertEqual(changed, true)
    }

}
#endif

/**
 iOS and tvOS
 */
extension UITabBarTests {

    func testDidSelectItem() {
        let subject = createSubject()

        let item = UITabBarItem()
        var returnedItem: UITabBarItem!

        _ = subject.rx.didSelectItem
            .subscribe(onNext: { i in
                returnedItem = i
            })
        
        subject.delegate!.tabBar!(subject, didSelect: item)
        
        XCTAssertEqual(returnedItem, item)
    }

}

#endif
