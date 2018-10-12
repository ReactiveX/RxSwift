//
//  UITabBarItem+RxTests.swift
//  Tests
//
//  Created by Mateusz Derks on 04/03/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UITabBarItemTests : RxTest {
}

extension UITabBarItemTests {
    func testBadgeValue_Text() {
        let subject = UITabBarItem(tabBarSystemItem: .more, tag: 0)
        Observable.just("5").subscribe(subject.rx.badgeValue).dispose()
        
        XCTAssertTrue(subject.badgeValue == "5")
    }
    
    func testBadgeValue_Empty() {
        let subject = UITabBarItem(tabBarSystemItem: .more, tag: 0)
        Observable.just(nil).subscribe(subject.rx.badgeValue).dispose()
        
        XCTAssertNil(subject.badgeValue)
    }
    
}

@available(tvOS 10.0, iOS 10.0, *)
extension UITabBarItemTests {
    
    func testBadgeColor_Color() {
        let subject = UITabBarItem(tabBarSystemItem: .more, tag: 0)
        let color = UIColor.blue
        Observable.just(color).subscribe(subject.rx.badgeColor).dispose()
        XCTAssertTrue(subject.badgeColor === color)
    }
    
    func testBadgeColor_Empty() {
        let subject = UITabBarItem(tabBarSystemItem: .more, tag: 0)
        Observable.just(nil).subscribe(subject.rx.badgeColor).dispose()
        
        XCTAssertNil(subject.badgeColor)
    }
}
