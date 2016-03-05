//
//  UITabBarItem+RxTests.swift
//  Rx
//
//  Created by Mateusz Derks on 04/03/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UITabBarItemTests : RxTest {
}

extension UITabBarItemTests {
    func testBadgetValue_Text() {
        let subject = UITabBarItem(tabBarSystemItem: .More, tag: 0)
        Observable.just("5").subscribe(subject.rx_badgeValue).dispose()
        
        XCTAssertTrue(subject.badgeValue == "5")
    }
    
    func testBadgetValue_Empty() {
        let subject = UITabBarItem(tabBarSystemItem: .More, tag: 0)
        Observable.just(nil).subscribe(subject.rx_badgeValue).dispose()
        
        XCTAssertTrue(subject.badgeValue == nil)
    }
}
