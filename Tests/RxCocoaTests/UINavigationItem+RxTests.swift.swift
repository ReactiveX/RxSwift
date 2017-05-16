//
//  UINavigationItem+RxTests.swift.swift
//  Tests
//
//  Created by kumapo on 2016/05/11.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UINavigationItemTests : RxTest {
}

extension UINavigationItemTests {
    func testTitle_Text() {
        let subject = UINavigationItem()
        Observable.just("Editing").subscribe(subject.rx.title).dispose()
        
        XCTAssertTrue(subject.title == "Editing")
    }
    
    func testTitle_Empty() {
        let subject = UINavigationItem()
        Observable.just(nil).subscribe(subject.rx.title).dispose()
        
        XCTAssertTrue(subject.title == nil)
    }
}
