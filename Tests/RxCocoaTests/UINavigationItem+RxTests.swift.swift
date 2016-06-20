//
//  UINavigationItem+RxTests.swift.swift
//  Rx
//
//  Created by kumapo on 2016/05/11.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UINavigationItemTests : RxTest {
}

extension UINavigationItemTests {
    func testTitle_Text() {
        let subject = UINavigationItem()
        Observable.just("Editing").subscribe(subject.rx_title).dispose()
        
        XCTAssertTrue(subject.title == "Editing")
    }
    
    func testTitle_Empty() {
        let subject = UINavigationItem()
        Observable.just(nil).subscribe(subject.rx_title).dispose()
        
        XCTAssertTrue(subject.title == nil)
    }
}