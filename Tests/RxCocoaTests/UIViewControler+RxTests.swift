//
//  UIViewControler+RxTests.swift
//  Tests
//
//  Created by Kyle Fuller on 30/05/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UITViewControllerTests : RxTest {
}

extension UITViewControllerTests {
  func testRxTitle() {
    let viewController = UIViewController()

    _ = Observable.just("title").bindTo(viewController.rx.title)

    XCTAssertEqual("title", viewController.title)
  }
}
