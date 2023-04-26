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
        
        XCTAssertEqual(subject.badgeValue, "5")
    }
    
    func testBadgeValue_Empty() {
        let subject = UITabBarItem(tabBarSystemItem: .more, tag: 0)
        Observable.just(nil).subscribe(subject.rx.badgeValue).dispose()
        
        XCTAssertNil(subject.badgeValue)
    }
}
